class PublisherStage < ActiveRecord::Base
  has_many :publishers
  has_one :sales_stage, as: :sales_stageable
  belongs_to :company

  delegate :name, :probability, :open, :active, :position, to: :sales_stage, allow_nil: true
end
