class FeedbackController < ApplicationController
  get '/' do
    protected!
    page = params.fetch('page', 1).to_i
    limit = params.fetch('limit', 5).to_i

    submissions = current_user.feedback_submissions.order(created_at: :desc).limit(limit).offset((page - 1) * limit)
    total_count = current_user.feedback_submissions.count
    has_more = total_count > (page * limit)

    json({ items: submissions, hasMore: has_more })
  end
end