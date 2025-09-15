class AgendaItem < ActiveRecord::Base
  self.inheritance_column = :_type_disabled 
  
  belongs_to :editor, class_name: 'User', optional: true
end