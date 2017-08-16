class ActivityType < ActiveRecord::Base
  default_scope { order(:position) }

  validates_uniqueness_of :position, scope: [:company_id]
end
