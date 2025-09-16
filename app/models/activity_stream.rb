class ActivityStream < ActiveRecord::Base
  belongs_to :actor, class_name: 'User', optional: true
  belongs_to :target, polymorphic: true, optional: true
end