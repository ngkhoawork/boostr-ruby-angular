class EgnyteFolder < ActiveRecord::Base
  belongs_to :subject, polymorphic: true, required: true

  validates :uuid, presence: true
end
