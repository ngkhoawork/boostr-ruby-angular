class TempIo < ActiveRecord::Base
  NO_MATCH_FILTER = 'no-match'.freeze

  belongs_to :company
  belongs_to :io
  has_many :display_line_items, dependent: :destroy
  has_one :currency, class_name: 'Currency', primary_key: 'curr_cd', foreign_key: 'curr_cd'

  validate :active_exchange_rate

  after_update do
    redirect_display_line_items() if io_id_changed? && io.present?
    update_io() if io_id_changed? && io.present?
  end

  scope :by_no_match, -> (filter_params) { where('io_id IS NULL') if filter_params.eql? NO_MATCH_FILTER }
  scope :by_start_date, -> (start_date, end_date) do
    where(start_date: start_date..end_date) if (start_date && end_date).present?
  end
  scope :by_names, -> (name) do
    if name.present?
      where('name ilike :name OR advertiser ilike :name OR agency ilike :name', name: "%#{name}%")
    end
  end

  def exchange_rate
    super || company.exchange_rate_for(currency: self.curr_cd, at_date: (self.created_at || Date.today))
  end

  def active_exchange_rate
    if curr_cd != 'USD'
      unless exchange_rate
        errors.add(:curr_cd, "does not have an exchange rate for #{self.curr_cd} at #{(self.created_at || Date.today).strftime("%m/%d/%Y")}")
      end
    end
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

  def as_json(options = {})
    super(options.deep_merge(
      include: {
        currency: { only: :curr_symbol }
      }
    ))
  end
end
