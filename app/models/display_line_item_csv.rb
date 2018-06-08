class DisplayLineItemCsv
  include ActiveModel::Validations

  validates_presence_of     :line_number, :start_date, :end_date, :product_name,
                            :quantity, :budget, :company_id#, :io_name
  validates_numericality_of :line_number, :quantity, :budget, :budget_delivered, numericality: true
  validates_numericality_of :quantity_delivered, :quantity_delivered_3p, allow_blank: true

  validate :io_exchange_rate_presence, if: :company_id
  validate :dates_can_be_parsed

  attr_accessor :external_io_number, :line_number, :ad_server, :start_date, :end_date,
                :product_name, :quantity, :price, :pricing_type, :budget, :budget_delivered,
                :quantity_delivered, :quantity_delivered_3p, :company_id, :ctr, :clicks,
                :io_name, :io_start_date, :io_end_date, :io_advertiser, :io_agency, :ad_unit_name,
                :product, :product_id, :ad_server_product

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    return self.errors.full_messages unless self.valid?
    update_external_io_number
    response = upsert_temp_io

    @parsed_start_date = parse_date(start_date)
    @parsed_end_date = parse_date(end_date)

    if io_or_tempio && display_line_item
      display_line_item.update(
        line_number: line_number,
        ad_server: ad_server,
        start_date: parsed_start_date,
        end_date: parsed_end_date,
        product: product,
        ad_server_product: get_ad_server_product,
        quantity: quantity,
        price: price,
        pricing_type: pricing_type,
        budget: io_or_tempio.convert_to_usd(budget),
        budget_loc: budget_loc,
        budget_delivered: io_or_tempio.convert_to_usd(budget_delivered),
        budget_delivered_loc: budget_delivered_loc,
        budget_remaining: io_or_tempio.convert_to_usd(budget_remaining),
        budget_remaining_loc: budget_remaining_loc,
        quantity_delivered: quantity_delivered,
        quantity_remaining: quantity_remaining,
        quantity_delivered_3p: quantity_delivered_3p,
        ctr: ctr,
        clicks: clicks,
        ad_unit: ad_unit_name,
        dont_update_parent_budget: true
      )

      update_io if io_can_be_updated?
    end
    response
  end

  private

  attr_reader :parsed_start_date, :parsed_end_date

  def display_line_item
    @_display_line_item ||= io_or_tempio.display_line_items.find_by_line_number(line_number)
    @_display_line_item ||= io_or_tempio.display_line_items.new
  end

  def io_or_tempio
    @first_lookup = true if @first_lookup.nil?

    if @first_lookup
      @first_lookup = false
      @parent_object = io || tempio
    else
      @parent_object
    end
  end

  def io
    return io_by_io_num unless io_by_io_num.nil?
    io_by_ext_num
  end

  def io_by_ext_num
    @_io_by_ext_num ||= Io.find_by(company_id: company_id, external_io_number: external_io_number)
  end

  def io_by_io_num
    if io_number
      @_io_by_io_num ||= Io.find_by(company_id: company_id, io_number: io_number)
    end
  end

  def tempio
    if io_name.present? && io_start_date.present? && io_end_date.present?
      @_temp_io ||= TempIo.find_or_initialize_by(company_id: company_id, external_io_number: external_io_number)
    else
      @_temp_io ||= TempIo.find_by(company_id: company_id, external_io_number: external_io_number)
    end
  end

  def upsert_temp_io
    return unless io_name.present? && io_start_date.present? && io_end_date.present?
    if io_or_tempio.kind_of? TempIo
      temp_io_params = {
          name: io_name,
          start_date: io_start_date,
          end_date: io_end_date,
          advertiser: io_advertiser,
          agency: io_agency
      }

      io_or_tempio.update!(
          temp_io_params
      )
      io_or_tempio.id
    end
  end

  def io_number
    io_name.gsub(/.+_/, '') if io_name
  end

  def update_external_io_number
    if io && external_io_number
      io.update_columns(external_io_number: external_io_number)
    end
  end

  def product
    if ad_server == 'DFP'
      @_product ||= ad_unit_product
    else
      @_product ||= Product.find_by(company_id: company_id, full_name: product_name)
      @_product ||= revenue_product
    end
  end

  def ad_unit_product
    if product_id
      Product.find_by(id: product_id)
    else
      Product.joins(:ad_units).find_by('ad_units.name = ? and products.company_id = ?', ad_unit_name, company_id)
    end
  end

  def budget_loc
    budget.to_f
  end

  def budget_delivered_loc
    budget_delivered
  end

  def budget_remaining
    budget.to_f - budget_delivered.to_f
  end

  def budget_remaining_loc
    budget_loc.to_f - budget_delivered_loc.to_f
  end

  def quantity_remaining
    quantity.to_f - quantity_delivered.to_f
  end

  def exchange_rate
    @_exchange_rate ||= io_or_tempio.exchange_rate
  end

  def exchange_rate_at_close
    @_exchange_rate_at_close ||= io_or_tempio.exchange_rate_at_close
  end

  def io_exchange_rate_presence
    if io_or_tempio && !(exchange_rate_at_close || exchange_rate)
      errors.add(:budget, "has no exchange rate for #{io_or_tempio.curr_cd} found at #{io_or_tempio.created_at.strftime("%m/%d/%Y")}")
    end
  end

  def dates_can_be_parsed
    unless start_date.present? && parse_date(start_date)
      errors.add(:start_date, 'failed to be parsed correctly')
    end
    unless end_date.present? && parse_date(end_date)
      errors.add(:end_date, 'failed to be parsed correctly')
    end
  end

  def revenue_product
    if io.present? && io.deal.present?
      io.deal.products.find_by(revenue_type: 'Display')
    end
  end

  def parse_date(str)
    return str if str.kind_of?(ActiveSupport::TimeWithZone) || str.kind_of?(Date)
    date_string = str.strip
    d = Date.parse date_string rescue nil
    d ||= Date.strptime(date_string, "%m/%d/%Y") rescue nil
    if d.present? && d.year < 100
      d = Date.strptime(date_string, "%m/%d/%y")
    end
    d
  end

  def start_end_date_present?
    parse_date(self.start_date).present? && parse_date(self.end_date).present?
  end

  def persisted?
    false
  end

  def update_io
    io.start_date = parsed_start_date if parsed_start_date < io.start_date
    io.end_date = parsed_end_date if parsed_end_date > io.end_date
    io.save
  end

  def io_can_be_updated?
    io && io.content_fees.count.zero? && parsed_start_date && parsed_end_date
  end

  def get_ad_server_product
    ad_server_product || product_name
  end
end
