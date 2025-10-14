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
end