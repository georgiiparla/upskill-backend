class QuestsController < ApplicationController
  get '/' do
    protected!
    quests_scope = Quest.order(id: :asc)
    if params['explicit_only']&.downcase == 'true'
      quests_scope = quests_scope.where(explicit: true)
    end

    quests = quests_scope
    progress_map = current_user.user_quests.where(quest_id: quests.map(&:id)).index_by(&:quest_id)

    quests_payload = quests.map do |quest|
      user_progress = progress_map[quest.id]

      quest.as_json.merge(
        'user_completed' => user_progress&.completed || false,
        'user_progress' => user_progress&.progress || 0
      )
    end

    json quests_payload
  end

  post '/' do
    protected!

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
    protected!

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
    protected!

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
end