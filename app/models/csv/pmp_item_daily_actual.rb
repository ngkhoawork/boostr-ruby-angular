require 'chronic'

class Csv::PmpItemDailyActual
  include ActiveModel::Validations

  attr_accessor :ssp_deal_id,
                :date,
                :ad_unit,
                :ad_requests,
                :impressions,
                :price,
                :revenue_loc,
                :win_rate,
                :curr_cd,
                :ssp_advertiser_name,
                :company,
                :user

  validates :date, :ad_unit, :company, presence: true
  validates :ad_requests, :impressions, presence: true, numericality: true
  validates :win_rate, numericality: true, allow_nil: true
  validate :validate_pmp_item_presence
  validate :validate_deal_id
  validate :validate_date_format
  validate :validate_ecpm
  validate :validate_revenue_loc
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def error_messages
    errors.messages.keys.map do |attr| 
      if attr == :base
        errors.full_messages_for(attr)
      else
        errors.full_messages_for(attr).first
      end
    end.flatten
  end

  def save
    pmp_item_daily_actual.date = parsed_date
    pmp_item_daily_actual.ad_unit = ad_unit
    pmp_item_daily_actual.pmp_item = pmp_item
    pmp_item_daily_actual.ad_requests = ad_requests
    pmp_item_daily_actual.impressions = impressions
    pmp_item_daily_actual.win_rate = win_rate
    pmp_item_daily_actual.price = price
    pmp_item_daily_actual.revenue_loc = revenue_loc
    pmp_item_daily_actual.imported = true
    pmp_item_daily_actual.ssp_advertiser = ssp_advertiser_name
    pmp_item_daily_actual.advertiser = advertiser
    pmp_item_daily_actual.save!
  end

  def pmp_item
    @_pmp_item ||= PmpItem.find_by(ssp_deal_id: ssp_deal_id)
  end

  def pmp_item_daily_actual
    @_pmp_item_daily_actual ||= if pmp_item.present?
      ::PmpItemDailyActual.find_or_initialize_by(pmp_item_id: pmp_item.id, date: parsed_date)
    else
      ::PmpItemDailyActual.new
    end
  end

  def product
    return nil if self.ad_unit.blank?
    ad_unit = AdUnit.where('lower(name) = ?', self.ad_unit.downcase).first
    if ad_unit
      ad_unit.product
    else
      Product.where('lower(name) = ?', self.ad_unit.downcase).first
    end
  end

  def self.import(file, current_user_id, file_path)
    user = User.find(current_user_id)
    company = user&.company
    return unless company.present?

    pmp_item_ids = []
    pmp_ids = []
    pmp_change = {time_period_ids: [], product_ids: [], user_ids: []}
    import_log = CsvImportLog.new(company_id: company.id, object_name: 'pmp_item_daily_actual', source: 'ui')
    import_log.set_file_source(file_path)

    SmarterCSV.process(file, { force_simple_split: true, strip_chars_from_headers: /[\-"]/ }).each do |row|
      import_log.count_processed

      csv_pmp_item_daily_actual = self.build(row, user)
      if csv_pmp_item_daily_actual.valid?
        begin
          csv_pmp_item_daily_actual.save
          import_log.count_imported

          pmp_item_ids << csv_pmp_item_daily_actual.pmp_item.id
          pmp_ids << csv_pmp_item_daily_actual.pmp_item.pmp.id

          pmp = csv_pmp_item_daily_actual.pmp_item.pmp
          pmp_change[:time_period_ids] += company.time_periods.for_time_period(pmp.start_date, pmp.end_date).collect{|item| item.id}
          pmp_change[:user_ids] += pmp.pmp_members.collect{|item| item.user_id}
          pmp_change[:product_ids] += [csv_pmp_item_daily_actual.pmp_item&.product_id]
        rescue Exception => e
          import_log.count_failed
          import_log.log_error ['Internal Server Error', row.to_h.compact.to_s, e.class]
          next
        end
      else
        import_log.count_failed
        import_log.log_error csv_pmp_item_daily_actual.error_messages
        next
      end
    end

    import_log.save

    PmpItemMonthlyActual.generate(pmp_item_ids.uniq)
    PmpItem.calculate(pmp_item_ids.uniq)
    Pmp.calculate_end_date(pmp_ids.uniq)

    pmp_change[:time_period_ids] = pmp_change[:time_period_ids].uniq
    pmp_change[:user_ids] = pmp_change[:user_ids].uniq
    pmp_change[:product_ids] = pmp_change[:product_ids].uniq

    ForecastPmpRevenueCalculatorWorker.perform_async(pmp_change)
  end

  private

  def advertiser
    @_advertiser ||= client || company.ssp_advertisers.find_by(name: ssp_advertiser_name, ssp: pmp_item&.ssp)&.client
  end

  def client
    client = company.clients.find_by(name: ssp_advertiser_name)
    if client.present?
      ssp_advertiser = company.ssp_advertisers.find_or_initialize_by(
        name: ssp_advertiser_name,
        ssp: pmp_item&.ssp
      )
      ssp_advertiser.client = client
      ssp_advertiser.created_by ||= user
      ssp_advertiser.updated_by = user
      ssp_advertiser.save!
    end
    client
  end

  def validate_ecpm
    validate_numeric('eCPM', price)
  end

  def validate_revenue_loc
    validate_numeric('Revenue', revenue_loc)
  end

  def validate_numeric(name, val)
    if val.blank?
      errors.add(:base, "#{name} can't be blank") 
    elsif val.is_a? String
      Float(val) rescue errors.add(:base, "#{name} is not a number") 
    elsif !val.is_a? Numeric
      errors.add(:base, "#{name} is not a number")
    end
  end

  def validate_pmp_item_presence
    errors.add(:pmp_item, "with Deal-Id #{ssp_deal_id} could not be found") if pmp_item.nil? && !ssp_deal_id.blank?
  end

  def validate_date_format
    errors.add(:date, "- #{date} must be in valid date format") unless date_valid?
  end

  def validate_deal_id
    errors.add(:base, "Deal-ID can't be blank") if ssp_deal_id.blank?
  end

  def parsed_date
    @_parsed_date ||= if date.present? && date_valid?
      d = Date.strptime(date, "%m/%d/%Y") 
      if d && d.year < 100
        d = Date.strptime(date, "%m/%d/%y")
      end
      d
    end
  end

  def date_valid?
    begin
      Date.strptime(date, "%m/%d/%Y") if date.present?
    rescue ArgumentError
      return false
    end
    return true
  end

  def self.build(row, user)
    Csv::PmpItemDailyActual.new(
      ssp_deal_id: row[:dealid],
      date: row[:date].try(:strip),
      ad_unit: row[:ad_unit],
      ad_requests: row[:ad_requests],
      impressions: row[:impressions],
      win_rate: row[:win_rate],
      price: row[:ecpm],
      revenue_loc: row[:revenue],
      curr_cd: row[:currency],
      ssp_advertiser_name: row[:ssp_advertiser],
      company: user&.company,
      user: user
    )
  end
end
