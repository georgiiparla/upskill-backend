class QuestsController < ApplicationController
  get '/' do
    protected!
    quests = Quest.order(id: :asc)
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

    begin
      q = Quest.create!(
        code: @request_payload['code'],
        title: @request_payload['title'],
        description: @request_payload['description'],
        points: @request_payload['points']
      )
      status 201
      json q
    rescue ActiveRecord::RecordInvalid => e
      status 422
      json({ error: e.record.errors.full_messages.join(', ') })
    end
  end
end