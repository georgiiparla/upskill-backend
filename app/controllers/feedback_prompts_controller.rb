class FeedbackPromptsController < ApplicationController
  get '/' do
    protected!
    prompts = FeedbackPrompt.includes(:requester).order(created_at: :desc)
    
    prompts_json = prompts.map do |p| 
      p.as_json.merge(requester_username: p.requester.username) 
    end

    json({ items: prompts_json, hasMore: false })
  end

  post '/' do
    protected!
    prompt = current_user.feedback_prompts.build(
      topic: @request_payload['topic'],
      details: @request_payload['details']
    )

    if prompt.save
      status 201
      json prompt
    else
      status 422
      json({ errors: prompt.errors.full_messages })
    end
  end
end