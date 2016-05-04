class Report < ActiveRecord::Base
  belongs_to :company
  belongs_to :user
  belongs_to :time_period
end
