class ActivityType < ActiveRecord::Base
  default_scope { order(:created_at) }

  scope :by_name, -> (name) { find_by(name: name) }
end
