require_relative '../helpers/anonymizer'
require_relative '../middleware/quest_middleware'

class FeedbackRequestsController < ApplicationController
  # GET /
  # Returns requests where current_user is requester OR pair
  get '/' do
    protected!

    # Efficient query using OR condition
    # Include:
    # 1. Requests where I am the requester
    # 2. Requests where I am the pair
    # 3. Requests that are PUBLIC (regardless of owner)
    all_requests = FeedbackRequest.includes(:requester, :pair)
                                  .where('requester_id = :current_user_id OR pair_id = :current_user_id OR visibility = :public_visibility', 
                                         current_user_id: current_user.id, 
                                         public_visibility: 'public')
                                  .order(created_at: :desc)

    if params['search'] && !params['search'].empty?
      search_term = "%#{params['search'].downcase}%"
      # Search in topic, tag, OR requester username, OR pair username
      # Need joins to filter by username
      all_requests = all_requests.left_joins(:requester, :pair).where(
        'lower(feedback_requests.topic) LIKE ? OR ' +
        'lower(feedback_requests.tag) LIKE ? OR ' +
        'lower(users.username) LIKE ? OR ' + 
        'lower(pairs_feedback_requests.username) LIKE ?',
        search_term, search_term, search_term, search_term
      )
    end

    requests_json = all_requests.map do |request|
      request.as_json.merge(
        requester_username: request.requester.username,
        pair_username: request.pair&.username,
        isOwner: request.requester_id == current_user.id || request.pair_id == current_user.id
      )
    end

    json({ items: requests_json, hasMore: false })
  end

  post '/' do
    protected!

    # FIX: Rate Limiting
    daily_limit = AppConfig::MAX_DAILY_FEEDBACK_REQUESTS
    today_count = current_user.feedback_requests
                              .where('created_at >= ?', Time.now.beginning_of_day)
                              .count

    if today_count >= daily_limit
      halt 429, json({ error: "Daily limit reached. You can create up to #{daily_limit} requests per day." })
    end

    request_params = @request_payload.slice('topic', 'details', 'tag', 'visibility')
    pair_username = @request_payload['pair_username']
    pair_user = nil

    if pair_username.present?
      pair_user = User.find_by(username: pair_username)
      if !pair_user
        halt 404, json({ error: "Pair user not found" })
      elsif pair_user.id == current_user.id
        halt 422, json({ error: "Cannot pair with yourself" })
      end
    end

    # Create Single Shared Request
    feedback_request = current_user.feedback_requests.build(request_params)
    feedback_request.pair = pair_user if pair_user

    if feedback_request.save
      ActivityStream.create(actor: current_user, event_type: 'feedback_requested', target: feedback_request)
      QuestMiddleware.trigger(current_user, 'FeedbackRequestsController#create')

      if pair_user
        ActivityStream.create(actor: pair_user, event_type: 'feedback_requested', target: feedback_request)
        QuestMiddleware.trigger(pair_user, 'FeedbackRequestsController#create')
      end

      status 201
      json feedback_request.as_json.merge(
        requester_username: current_user.username,
        pair_username: pair_user&.username,
        isOwner: true # Creator is always an owner
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
      is_owner = request.requester_id == current_user.id || request.pair_id == current_user.id
      can_view_all_submissions = request.visibility == 'public' || is_owner

      submissions_to_process = []

      if can_view_all_submissions
        # If public or owner, get all submissions
        submissions_to_process = request.feedback_submissions.includes(:user,
                                                                       :feedback_submission_likes).order(created_at: :desc)
      else
        # If private and not the owner, get ONLY the current user's submissions
        submissions_to_process = request.feedback_submissions.where(user: current_user).includes(:user,
                                                                                                 :feedback_submission_likes).order(created_at: :desc)
      end

      submissions_json = []
      if submissions_to_process.any?
        author_to_anonymous_name = {}
        submissions_json = submissions_to_process.map do |s|
          anonymous_name = author_to_anonymous_name.fetch(s.user.id) do |user_id|
            new_name = Anonymizer.generate_name
            new_name = Anonymizer.generate_name while author_to_anonymous_name.has_value?(new_name)
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
    halt 404, json({ error: 'Feedback request not found.' }) unless feedback_request

    if feedback_request.requester_id != current_user.id && feedback_request.pair_id != current_user.id
      halt 403, json({ error: 'You are not authorized to modify this request.' })
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
      json({ errors: feedback_request.errors.full_messages.presence || 'Invalid status provided.' })
    end
  end

  patch '/:id/visibility' do
    protected!

    feedback_request = FeedbackRequest.find_by(id: params['id'])
    halt 404, json({ error: 'Feedback request not found.' }) unless feedback_request

    if feedback_request.requester_id != current_user.id && feedback_request.pair_id != current_user.id
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

    halt 404, json({ error: 'Feedback request not found.' }) unless feedback_request

    if feedback_request.requester_id != current_user.id && feedback_request.pair_id != current_user.id
      halt 403, json({ error: 'You are not authorized to delete this request.' })
    end

    if feedback_request.destroy
      # Revert points for Requester
      if feedback_request.requester
        QuestMiddleware.revert(feedback_request.requester, 'FeedbackRequestsController#create')
      end

      # Revert points for Pair (if exists)
      if feedback_request.pair
        QuestMiddleware.revert(feedback_request.pair, 'FeedbackRequestsController#create')
      end
      
      status 200
      json({ message: 'Feedback request deleted successfully.' })
    else
      status 500
      json({ error: 'Failed to delete the feedback request.' })
    end
  end
end
