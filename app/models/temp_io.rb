class TempIo < ActiveRecord::Base
  belongs_to :company
  belongs_to :io
  has_many :display_line_items

  after_update do
    redirect_display_line_items() if io_id_changed? && io.present?
    update_io() if io_id_changed? && io.present?
  end

  def exchange_rate
    company.exchange_rate_for(currency: self.curr_cd, at_date: self.created_at)
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

  def update_io
    if start_date < io.start_date
      io.start_date = start_date
    end
    if end_date > io.end_date
      io.end_date = end_date
    end
    io.external_io_number = external_io_number
    io.save
  end
end
