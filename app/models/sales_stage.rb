class SalesStage < ActiveRecord::Base
  belongs_to :company
  belongs_to :sales_stageable, polymorphic: true

  validates :name, :probability, presence: true
  before_create :set_position

  private

  def set_position
    self.position ||= SalesStage.count
  end
end
