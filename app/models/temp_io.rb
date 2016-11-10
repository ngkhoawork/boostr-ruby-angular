class TempIo < ActiveRecord::Base
  belongs_to :company
  belongs_to :io
  has_many :display_line_items

  after_update do
    redirect_display_line_items() if io_id_changed? && io.present?
  end

  def redirect_display_line_items
    display_line_items.each do |display_line_item|
      display_line_item.io_id = io.id
      display_line_item.save
    end
    if io.deal.present?
      io.deal.close_display_product()
    end
  end


end
