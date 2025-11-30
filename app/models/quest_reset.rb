class QuestReset < ActiveRecord::Base
  belongs_to :quest

  validates :quest_id, uniqueness: true
end
