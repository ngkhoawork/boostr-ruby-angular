class ProductDimension < ActiveRecord::Base
  belongs_to :company

  before_save :set_top_parent_id

  private

  def set_top_parent_id
    self.top_parent_id ||= id
  end
end
