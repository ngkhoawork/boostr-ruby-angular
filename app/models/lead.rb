class Lead < ActiveRecord::Base
  ACCEPTED = 'accepted'.freeze
  REJECTED = 'rejected'.freeze

  belongs_to :company
  belongs_to :user

  scope :new_records, -> { where(status: nil) }
  scope :accepted, -> { where(status: ACCEPTED) }
  scope :rejected, -> { where(status: REJECTED) }
end
