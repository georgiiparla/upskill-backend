class AgendaItem < ActiveRecord::Base
  self.inheritance_column = :_type_disabled 
end