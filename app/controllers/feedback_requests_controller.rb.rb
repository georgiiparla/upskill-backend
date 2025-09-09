class FeedbackRequestsController < ApplicationController
  get '/' do
    protected!
    
    all_requests = FeedbackRequest.includes(:requester).order(created_at: :desc)
    
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
    
    request_params = @request_payload.slice('topic', 'details', 'tag')
    feedback_request = current_user.feedback_requests.build(request_params)

    if feedback_request.save
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
      submissions = request.feedback_submissions.includes(:user).order(created_at: :desc)
      
      submissions_json = submissions.map do |s|
        s.as_json.merge(authorName: s.user.username)
      end

      json({
        requestData: request.as_json.merge(
          requester_username: request.requester.username,
          isOwner: request.requester_id == current_user.id
        ),
        submissions: submissions_json
      })
    else
      status 404
      json({ error: "Request not found for tag '#{params['tag']}'" })
    end
  end

  delete '/:id' do
    protected!

    feedback_request = FeedbackRequest.find_by(id: params['id'])
    
    # Check if the request exists
    unless feedback_request
      halt 404, json({ error: "Feedback request not found." })
    end

    # Check if the current user is the owner of the request
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