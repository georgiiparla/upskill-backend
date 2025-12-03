require_relative '../middleware/quest_middleware'

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
      QuestMiddleware.trigger(current_user, 'FeedbackSubmissionsController#create')
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
          QuestMiddleware.revert(current_user, 'FeedbackSubmissionsController#create')
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
    submission = FeedbackSubmission.find_by(id: params[:id])
    halt 404, json({ error: 'Submission not found' }) unless submission

    # 1. Prevent Self-Likes
    if submission.user_id == current_user.id
       halt 422, json({ error: 'You cannot like your own feedback.' })
    end

    # 2. Rate Limit Check (Standard validation)
    daily_likes_count = FeedbackSubmissionLike.where(user: current_user)
                                              .where('created_at >= ?', Time.now.beginning_of_day)
                                              .count
    if daily_likes_count >= AppConfig::MAX_DAILY_LIKES
      halt 422, json({ error: "Daily limit reached." })
    end

    # 3. Idempotent Creation
    like = FeedbackSubmissionLike.find_or_initialize_by(user: current_user, feedback_submission: submission)
    is_new_like = like.new_record? # Capture state before save

    if like.save
      # Only award points if this is actually a NEW like
      if is_new_like
        QuestMiddleware.trigger(current_user, 'FeedbackSubmissionsController#like')
        QuestMiddleware.trigger(submission.user, 'FeedbackSubmissionsController#like_received')
      end
      json({ success: true, likes: submission.likes.count })
    else
      halt 500, json({ error: 'Failed to like submission' })
    end
  end

  # DELETE /:id/like
  delete '/:id/like' do
    protected!
    submission = FeedbackSubmission.find_by(id: params[:id])
    halt 404, json({ error: 'Submission not found' }) unless submission

    current_count = submission.likes.count

    # SECURITY FIX: Transaction + Locking to prevent race conditions
    ActiveRecord::Base.transaction do
      # Attempt to lock the specific like record
      like = FeedbackSubmissionLike.lock.find_by(user: current_user, feedback_submission: submission)
      
      if like
        like.destroy
        # Revert Points (Symmetry) - uses atomic decrement in UserQuest
        QuestMiddleware.revert(current_user, 'FeedbackSubmissionsController#like')
        QuestMiddleware.revert(submission.user, 'FeedbackSubmissionsController#like_received')
        
        current_count -= 1
      end
    end
    
    json({ success: true, likes: current_count })
  end
end