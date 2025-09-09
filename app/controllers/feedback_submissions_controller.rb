class FeedbackSubmissionsController < ApplicationController
  get '/' do
    protected!
    page = params.fetch('page', 1).to_i
    limit = params.fetch('limit', 5).to_i

    submissions = current_user.feedback_submissions.order(created_at: :desc).limit(limit).offset((page - 1) * limit)
    total_count = current_user.feedback_submissions.count
    has_more = total_count > (page * limit)

    json({ items: submissions, hasMore: has_more })
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
      sentiment: @request_payload['sentiment'],
      subject: "Re: #{feedback_request.topic}"
    )

    if submission.save
      status 201
      json submission.as_json.merge(authorName: current_user.username)
    else
      status 422
      json({ errors: submission.errors.full_messages })
    end
  end
end