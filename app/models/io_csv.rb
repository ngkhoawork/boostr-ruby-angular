class IoCsv
  include ActiveModel::Validations
  validates :io_external_number, :io_name, :io_start_date, :io_end_date, :io_budget,
            :io_curr_cd, :io_advertiser, :company_id, presence: true

  validates :io_external_number, :io_budget,
  numericality: true

  validate :dates_can_be_parsed
  validate :record_has_exchange_rate

  attr_accessor(
    :io_external_number, :io_name, :io_start_date, :io_end_date, :io_advertiser,
    :io_agency, :io_budget, :io_budget_loc, :io_curr_cd, :company_id,
    :auto_close_deals, :exchange_rate_at_close
  )

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    return self.errors.full_messages unless self.valid?
    close_deal_from_io_number if auto_close_deals
    if io.present?
      update_io
    else
      upsert_temp_io
    end
  end

  private

  def close_deal_from_io_number
    deal = Deal.find_by(id: io_number, company_id: company_id)
    if deal.present? && deal.closed_won? == false
      deal.update(stage: Stage.closed_won(company_id), updated_by: 0)
    end
  end

  def io
    @_io ||= Io.find_by(company_id: company_id, external_io_number: io_external_number)
    if @_io.nil? && io_name && io_name.split('_').count > 1 && io_number
      @_io ||= Io.find_by(company_id: company_id, io_number: io_number)
    end
    @_io
  end

  def temp_io
    @_temp_io ||= TempIo.find_or_initialize_by(
      company_id: company_id,
      external_io_number: io_external_number,
      curr_cd: io_curr_cd
    )
  end

  def update_io
    if io.content_fees.count == 0 && io_start_date && start_date
      io.start_date = start_date
    end

    if io.content_fees.count == 0 && io_end_date && end_date
      io.end_date = end_date
    end

    io.update(
      external_io_number: io_external_number,
      exchange_rate_at_close: exchange_rate_at_close,
      budget: convert_currency(io_budget),
      budget_loc: io_budget_loc
    )
  end

  def upsert_temp_io
    temp_io_params = {
      external_io_number: io_external_number.to_i,
      name: io_name,
      start_date: start_date,
      end_date: end_date,
      advertiser: io_advertiser,
      agency: io_agency,
      budget: convert_currency(io_budget),
      budget_loc: io_budget_loc,
      curr_cd: io_curr_cd,
      exchange_rate_at_close: exchange_rate_at_close
    }

    temp_io.update(
      temp_io_params
    )
    temp_io.id
  end

  def io_number
    @_io_number ||= io_name.split('_').last.to_i rescue nil
  end

  def parse_date(str)
    date_string = str.strip
    d = Date.parse date_string rescue nil
    d ||= Date.strptime(date_string, "%m/%d/%Y") rescue nil
    if d.present? && d.year < 100
      d = Date.strptime(date_string, "%m/%d/%y")
    end
    d
  end

  def dates_can_be_parsed
    unless io_start_date.present? && start_date
      errors.add(:io_start_date, 'failed to be parsed correctly')
    end
    unless io_end_date.present? && end_date
      errors.add(:io_end_date, 'failed to be parsed correctly')
    end
  end

  def record_has_exchange_rate
    if (io || temp_io).present? && (io || temp_io).company.present? && !(exchange_rate_at_close || item_exchange_rate).present?
      errors.add(:io_curr_cd, "#{io_curr_cd} does not have an exchange rate available at the moment")
    end
  end

  def start_date
    parse_date(io_start_date)
  end

  def end_date
    parse_date(io_end_date)
  end

  def persisted?
    false
  end

  def convert_currency(value)
    if exchange_rate_at_close
      value.to_f * exchange_rate_at_close.to_f
    else
      value.to_f / item_exchange_rate.to_f
    end
  end

  def item_exchange_rate
    @_exchange_rate ||= (io || temp_io).exchange_rate
  end
end
