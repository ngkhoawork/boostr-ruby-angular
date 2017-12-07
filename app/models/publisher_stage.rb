class PublisherStage < ActiveRecord::Base
  has_many :publishers
  has_one :sales_stage, as: :sales_stageable
  belongs_to :company

  delegate :name, :probability, :open, :active, :position, to: :sales_stage, allow_nil: true

  scope :active, -> { joins(:sales_stage).where(sales_stages: { active: true }) }
  scope :order_by_position, -> { joins(:sales_stage).order('sales_stages.position') }
  scope :order_by_open_and_probability, -> do
    joins(:sales_stage).order('sales_stages.open DESC, sales_stages.probability ASC')
  end
end
