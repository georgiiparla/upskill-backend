class Quest < ActiveRecord::Base
  has_many :user_quests, dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :title, presence: true
end