require_relative '../helpers/anonymizer'

class FeedbackRequestsController < ApplicationController
  get '/' do
    protected!
    
    all_requests = FeedbackRequest.includes(:requester).order(created_at: :desc)
    
    if params['search'] && !params['search'].empty?
      search_term = "%#{params['search'].downcase}%"
      all_requests = all_requests.joins(:requester).where(
        "lower(feedback_requests.topic) LIKE ? OR " +
        "lower(feedback_requests.tag) LIKE ? OR " +
        "lower(users.username) LIKE ?",
        search_term, search_term, search_term
      )
    end

    requests_json = all_requests.map do |request| 
      request.as_json.merge(
        requester_username: request.requester.username,
        isOwner: request.requester_id == current_user.id
      )
    end

    json({ items: requests_json, hasMore: false })
  end

  post '/' do
    protected!
    
    request_params = @request_payload.slice('topic', 'details', 'tag', 'visibility')
    feedback_request = current_user.feedback_requests.build(request_params)

    if feedback_request.save
      ActivityStream.create(actor: current_user, event_type: 'feedback_requested', target: feedback_request)
      status 201
      json feedback_request.as_json.merge(
        requester_username: current_user.username,
        isOwner: true 
      )
    else
      status 422
      json({ errors: feedback_request.errors.full_messages })
    end
  end

  get '/:tag' do
    protected!
    
    request = FeedbackRequest.find_by(tag: params['tag'])

    if request
      is_owner = request.requester_id == current_user.id
      can_view_submissions = request.visibility == 'public' || is_owner
      
      submissions_json = []

      if can_view_submissions
        submissions = request.feedback_submissions.includes(:user, :feedback_submission_likes).order(created_at: :desc)
        author_to_anonymous_name = {}
        submissions_json = submissions.map do |s|
          anonymous_name = author_to_anonymous_name.fetch(s.user.id) do |user_id|
            new_name = Anonymizer.generate_name
            while author_to_anonymous_name.has_value?(new_name)
              new_name = Anonymizer.generate_name
            end
            author_to_anonymous_name[user_id] = new_name
          end
          s.as_json.merge(
            authorName: anonymous_name,
            isCommentOwner: s.user_id == current_user.id,
            likes: s.feedback_submission_likes.size,
            initialLiked: s.feedback_submission_likes.any? { |like| like.user_id == current_user.id }
          )
        end
      end

      json({
        requestData: request.as_json.merge(
          requester_username: request.requester.username,
          isOwner: is_owner
        ),
        submissions: submissions_json
      })
    else
      status 404
      json({ error: "Request not found for tag '#{params['tag']}'" })
    end
  end

  patch '/:id' do
    protected!

    feedback_request = FeedbackRequest.find_by(id: params['id'])
    halt 404, json({ error: "Feedback request not found." }) unless feedback_request
    
    if feedback_request.requester_id != current_user.id
      halt 403, json({ error: "You are not authorized to modify this request." })
    end

    new_status = @request_payload['status']
    if new_status == 'closed' && feedback_request.update(status: new_status)
      ActivityStream.create(actor: current_user, event_type: 'feedback_closed', target: feedback_request)
      json feedback_request.as_json.merge(
        requester_username: feedback_request.requester.username,
        isOwner: true
      )
    else
      status 422
      json({ errors: feedback_request.errors.full_messages.presence || "Invalid status provided." })
    end
  end

  patch '/:id/visibility' do
    protected!

    feedback_request = FeedbackRequest.find_by(id: params['id'])
    halt 404, json({ error: "Feedback request not found." }) unless feedback_request

    if feedback_request.requester_id != current_user.id
      halt 403, json({ error: "You are not authorized to change this request's visibility." })
    end

    new_visibility = @request_payload['visibility']
    feedback_request.visibility = new_visibility

    if feedback_request.save
      json feedback_request.as_json.merge(
        requester_username: feedback_request.requester.username,
        isOwner: true
      )
    else
      status 422
      json({ errors: feedback_request.errors.full_messages })
    end
  end

  delete '/:id' do
    protected!

    feedback_request = FeedbackRequest.find_by(id: params['id'])
    
    unless feedback_request
      halt 404, json({ error: "Feedback request not found." })
    end

    if feedback_request.requester_id != current_user.id
      halt 403, json({ error: "You are not authorized to delete this request." })
    end

    if feedback_request.destroy
      status 200
      json({ message: "Feedback request deleted successfully." })
    else
      status 500
      json({ error: "Failed to delete the feedback request." })
    end
  end
end