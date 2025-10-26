require_relative '../helpers/quest_updater'

class FeedbackSubmissionsController < ApplicationController
  get '/' do
    protected!
    page = params.fetch('page', 1).to_i
    limit = params.fetch('limit', 25).to_i

    submissions = current_user.feedback_submissions.includes(:feedback_request).order(created_at: :desc).limit(limit).offset((page - 1) * limit)
    total_count = current_user.feedback_submissions.count
    has_more = total_count > (page * limit)

    submissions_json = submissions.map do |submission|
      submission.as_json.merge(
        request_tag: submission.feedback_request&.tag
      )
    end

    json({ items: submissions_json, hasMore: has_more })
  end

  post '/' do
    protected!
    
    request_tag = @request_payload['request_tag']
    halt 400, json({ error: "request_tag is required." }) unless request_tag

    feedback_request = FeedbackRequest.find_by(tag: request_tag)
    halt 404, json({ error: "Feedback request with tag '#{request_tag}' not found." }) unless feedback_request

    submission = current_user.feedback_submissions.build(
      feedback_request: feedback_request,
      content: @request_payload['content'],
      sentiment: @request_payload['sentiment'].to_i,
      subject: feedback_request.topic
    )

    if submission.save
      QuestUpdater.complete_for(current_user, 'give_feedback')
      status 201
      json submission.as_json.merge(authorName: current_user.username)
    else
      status 422
      json({ errors: submission.errors.full_messages })
    end
  end

  delete '/:id' do
    protected!
    submission = FeedbackSubmission.find_by(id: params['id'])
    halt 404, json({ error: 'Submission not found.' }) unless submission

    if submission.user_id != current_user.id
      halt 403, json({ error: 'You are not authorized to delete this submission.' })
    end

    if submission.destroy
      # If the user has no remaining feedback submissions, revert the 'give_feedback' one-time quest
      begin
        remaining = FeedbackSubmission.where(user_id: current_user.id).exists?
        unless remaining
          QuestUpdater.revert_for(current_user, 'give_feedback')
        end
      rescue => e
        puts "Failed to revert give_feedback quest for user #{current_user.id}: #{e.message}"
      end

      json({ message: 'Submission deleted successfully.' })
    else
      status 500
      json({ error: 'Failed to delete submission.' })
    end
  end

  post '/:id/like' do
    protected!
    submission = FeedbackSubmission.find_by(id: params['id'])
    halt 404, json({ error: 'Submission not found.' }) unless submission


    like = submission.feedback_submission_likes.new(user: current_user)
    if like.save
      QuestUpdater.complete_for(current_user, 'like_feedback') unless submission.user_id == current_user.id
      status 201
      json({ message: 'Liked successfully.' })
    else
      status 422
      json({ errors: like.errors.full_messages })
    end
  end

  delete '/:id/like' do
    protected!
    submission = FeedbackSubmission.find_by(id: params['id'])
    halt 404, json({ error: 'Submission not found.' }) unless submission

    like = submission.feedback_submission_likes.find_by(user: current_user)
    if like
      like.destroy

      # If the user has no remaining likes, revert the one-time 'like_feedback' quest
      begin
        remaining_likes = FeedbackSubmissionLike.where(user_id: current_user.id).exists?
        unless remaining_likes
          QuestUpdater.revert_for(current_user, 'like_feedback')
        end
      rescue => e
        # Log but do not fail the unlike action
        puts "Failed to revert like_feedback quest for user #{current_user.id}: #{e.message}"
      end

      json({ message: 'Unliked successfully.' })
    else
      status 404
      json({ error: 'Like not found.' })
    end
  end
end