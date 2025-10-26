class Quest < ActiveRecord::Base
  has_many :user_quests, dependent: :destroy

  attribute :explicit, :boolean, default: true

  validates :code, presence: true, uniqueness: true
  validates :title, presence: true
end