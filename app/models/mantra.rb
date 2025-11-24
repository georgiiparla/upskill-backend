class Mantra < ActiveRecord::Base
  validates :text, presence: true
  has_many :agenda_items
end
