class AgendaItem < ActiveRecord::Base
  self.inheritance_column = :_type_disabled 
  
  belongs_to :editor, class_name: 'User', optional: true
  belongs_to :mantra, optional: true

  has_many :activity_streams, as: :target, dependent: :destroy
end