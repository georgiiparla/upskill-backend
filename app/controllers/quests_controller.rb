class QuestsController < ApplicationController
  get '/' do
    protected!
    quests_scope = Quest.order(id: :asc)
    if params['explicit_only']&.downcase == 'true'
      quests_scope = quests_scope.where(explicit: true)
    end

    quests = quests_scope
    progress_map = current_user.user_quests.where(quest_id: quests.map(&:id)).index_by(&:quest_id)
    
    # Track when user last viewed quests
    last_viewed_quests = current_user.last_viewed_quests

    quests_payload = quests.map do |quest|
      user_progress = progress_map[quest.id]

      # For "always" quests, check if points were awarded since last view
      has_new_progress = false
      if quest.quest_type == 'always' && user_progress&.first_awarded_at
        has_new_progress = !last_viewed_quests || user_progress.first_awarded_at > last_viewed_quests
      end

      quest_data = quest.as_json.merge(
        'user_completed' => user_progress&.completed || false,
        'last_triggered_at' => user_progress&.last_triggered_at,
        'first_awarded_at' => user_progress&.first_awarded_at,
        'has_new_progress' => has_new_progress
      )

      # Add reset timing information for interval-based quests
      if quest.quest_type == 'interval-based' && quest.reset_interval_seconds&.positive?
        quest_data.merge!(
          'reset_interval_seconds' => quest.reset_interval_seconds,
          'last_reset_at' => quest.reset_schedule.reset_at,
          'next_reset_at' => quest.next_reset_at,
          'will_reset_on_next_trigger' => quest.will_reset_on_next_trigger?
        )
      elsif quest.quest_type == 'always'
        quest_data.merge!(
          'reset_interval_seconds' => nil,
          'last_reset_at' => nil,
          'next_reset_at' => nil,
          'will_reset_on_next_trigger' => false
        )
      end

      quest_data
    end

    # Update last_viewed_quests timestamp
    current_user.update_column(:last_viewed_quests, Time.now.utc)

    json quests_payload
  end

  post '/' do
    admin_protected!

    explicit_value = if @request_payload.key?('explicit')
      ActiveRecord::Type::Boolean.new.cast(@request_payload['explicit'])
    else
      true
    end

    if explicit_value.nil?
      status 422
      return json({ error: 'Explicit must be true or false' })
    end

    begin
      q = Quest.create!(
        code: @request_payload['code'],
        title: @request_payload['title'],
        description: @request_payload['description'],
        points: @request_payload['points'],
        explicit: explicit_value
      )
      status 201
      json q
    rescue ActiveRecord::RecordInvalid => e
      status 422
      json({ error: e.record.errors.full_messages.join(', ') })
    end
  end

  patch '/:id' do
    admin_protected!

    quest = Quest.find_by(id: params[:id])
    unless quest
      status 404
      return json({ error: 'Quest not found' })
    end

    updates = {}

    if @request_payload.key?('points')
      begin
        points_value = Integer(@request_payload['points'])
      rescue ArgumentError, TypeError
        status 422
        return json({ error: 'Points must be a valid integer' })
      end

      if points_value.negative?
        status 422
        return json({ error: 'Points must be greater than or equal to 0' })
      end

      updates[:points] = points_value
    end

    if @request_payload.key?('explicit')
      explicit_value = ActiveRecord::Type::Boolean.new.cast(@request_payload['explicit'])
      if explicit_value.nil?
        status 422
        return json({ error: 'Explicit must be true or false' })
      end
      updates[:explicit] = explicit_value
    end

    if @request_payload.key?('reset_interval_seconds')
      begin
        reset_value = Integer(@request_payload['reset_interval_seconds'])
      rescue ArgumentError, TypeError
        status 422
        return json({ error: 'Reset interval must be a valid integer' })
      end

      if reset_value.negative?
        status 422
        return json({ error: 'Reset interval must be greater than or equal to 0' })
      end

      updates[:reset_interval_seconds] = reset_value
    end

    if updates.empty?
      status 400
      return json({ error: 'No valid attributes provided for update' })
    end

    begin
      quest.update!(updates)
      json quest
    rescue ActiveRecord::RecordInvalid => e
      status 422
      json({ error: e.record.errors.full_messages.join(', ') })
    end
  end

  delete '/:id' do
    admin_protected!

    quest = Quest.find_by(id: params[:id])
    unless quest
      status 404
      return json({ error: 'Quest not found' })
    end

    begin
      quest.destroy!
      status 200
      json({ message: 'Quest deleted successfully.' })
    rescue ActiveRecord::RecordNotDestroyed => e
      status 422
      json({ error: e.message })
    rescue StandardError => e
      status 500
      json({ error: e.message })
    end
  end

  get '/admin' do
    admin_protected!
    
    quests = Quest.order(id: :asc)
    admin_quests_payload = quests.map do |quest|
      quest_data = quest.as_json

      # Add raw timing data for interval-based quests
      if quest.quest_type == 'interval-based' && quest.reset_interval_seconds&.positive?
        quest_data.merge!(
          'reset_interval_seconds' => quest.reset_interval_seconds,
          'last_reset_at' => quest.reset_schedule.reset_at,
          'next_reset_at' => quest.next_reset_at,
          'will_reset_on_next_trigger' => quest.will_reset_on_next_trigger?,
          'completed_users_count' => quest.user_quests.where(completed: true).count,
          'total_users_count' => quest.user_quests.count
        )
      elsif quest.quest_type == 'always'
        quest_data.merge!(
          'reset_interval_seconds' => nil,
          'last_reset_at' => nil,
          'next_reset_at' => nil,
          'will_reset_on_next_trigger' => false,
          'completed_users_count' => quest.user_quests.where(completed: true).count,
          'total_users_count' => quest.user_quests.count
        )
      end

      quest_data
    end

    json admin_quests_payload
  end

  private
end