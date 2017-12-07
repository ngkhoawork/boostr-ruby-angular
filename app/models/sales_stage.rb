class SalesStage < ActiveRecord::Base
  belongs_to :company
  belongs_to :sales_stageable, polymorphic: true

  validates :name, :probability, presence: true
  before_create :set_position

  scope :order_by_position, -> { order(:position) }

  private

  def set_position
    self.position ||= company.sales_stages.count
  end
end
