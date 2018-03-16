require 'chronic'

class Csv::PmpItemDailyActual
  ALLOWED_ATTRIBUTES = %i[date ad_unit ad_requests impressions win_rate price revenue revenue_loc
                          pmp_item_id md5_signature ssp_advertiser imported advertiser_id].freeze
  CSV_OPTIONS = { force_simple_split: true, strip_chars_from_headers: /[\-"]/ }.freeze

  attr_reader :user, :company, :file, :pmp_ids, :pmp_item_ids, :import_log, :advertisers, :pmp_change

  def self.import(*args)
    new(*args).import
  end

  def initialize(file, user_id, file_path)
    @user           = User.find(user_id)
    @company        = user&.company

    return unless company

    @file           = file
    @pmp_ids        = []
    @pmp_item_ids   = []
    @import_log     = CsvImportLog.new(company_id: company.id, object_name: 'pmp_item_daily_actual', source: 'ui')
    import_log.set_file_source(file_path)

    ssp_advertisers = company.ssp_advertisers.pluck(:name, :client_id).to_h
    @advertisers    = ssp_advertisers.merge(company.clients.pluck(:name, :id).to_h)
    @pmp_change     = { time_period_ids: [], product_ids: [], user_ids: [] }
  end

  def import
    SmarterCSV.process(file, CSV_OPTIONS).each do |row|
      import_log.count_processed

      daily_actual = find_or_build_daily_actual(prepare_params(row))

      if validate_daily_actual(daily_actual, row)
        daily_actual.save
        import_log.count_imported

        pmp_item_ids << daily_actual.pmp_item.id
        pmp_ids << daily_actual.pmp_item.pmp.id

        update_pmp_change(daily_actual.pmp_item)
      else
        import_log.count_failed
        import_log.log_error daily_actual.errors.full_messages
      end
    end

    import_log.save

    recalculate_dates_and_budgets
    schedule_forecast_recalculation
  end

  private

  def prepare_params(row)
    pmp_item = PmpItem.find_by(ssp_deal_id: row[:dealid])
    date = parse_date(row[:date]&.strip)

    {
      date:           date,
      ad_unit:        row[:ad_unit],
      pmp_item_id:    pmp_item&.id,
      ad_requests:    row[:ad_requests],
      impressions:    row[:impressions],
      win_rate:       row[:win_rate],
      price:          row[:ecpm],
      revenue_loc:    row[:revenue],
      imported:       true,
      ssp_advertiser: row[:ssp_advertiser],
      advertiser_id:  advertiser_id(row[:ssp_advertiser], pmp_item),
      md5_signature:  md5_signature(date, row[:dealid], row[:ad_unit], row[:ssp_advertiser])
    }
  end

  def find_or_build_daily_actual(params)
    daily_actual = ::PmpItemDailyActual.find_or_initialize_by(md5_signature: params[:md5_signature])
    daily_actual.assign_attributes(params.slice(*ALLOWED_ATTRIBUTES))
    daily_actual
  end

  def parse_date(string)
    return if string.nil?

    date_format = string[/\d{4}/].present? ? '%m/%d/%Y' : '%m/%d/%y'
    Date.strptime(string, date_format)
  end

  def advertiser_id(ssp_advertiser_name, pmp_item)
    return if ssp_advertiser_name.nil?

    advertiser_id = advertisers[ssp_advertiser_name]

    if advertiser_id.present?
      SspAdvertiser.create_or_update(ssp_advertiser_name, advertiser_id, pmp_item&.ssp&.id, user)
    end

    advertiser_id
  end

  def md5_signature(date, ssp_deal_id, ad_unit, ssp_advertiser_name)
    Digest::MD5.hexdigest("#{date}#{ssp_deal_id}#{ad_unit}#{ssp_advertiser_name}")
  end

  def update_pmp_change(pmp_item)
    pmp = pmp_item.pmp

    pmp_change[:time_period_ids] += company.time_periods.for_time_period(pmp.start_date, pmp.end_date).collect{|item| item.id}
    pmp_change[:user_ids] += pmp.pmp_members.collect{|item| item.user_id}
    pmp_change[:product_ids] << pmp_item&.product_id
  end

  def recalculate_dates_and_budgets
    PmpItemMonthlyActual.generate(pmp_item_ids.uniq)
    PmpItem.calculate(pmp_item_ids.uniq)
    Pmp.calculate_dates(pmp_ids.uniq)
  end

  def schedule_forecast_recalculation
    pmp_change[:time_period_ids].uniq!
    pmp_change[:user_ids].uniq!
    pmp_change[:product_ids].uniq!

    ForecastPmpRevenueCalculatorWorker.perform_async(pmp_change)
  end

  def validate_daily_actual(daily_actual, row)
    daily_actual.valid?

    daily_actual.errors.tap do |errors|
      errors.add(:base, "Deal-ID can't be blank") if row[:dealid].blank?
      errors.add(:pmp_item, "with Deal-Id #{row[:dealid]} could not be found") unless daily_actual.pmp_item
      errors.add(:date, "- #{row[:date]} must be in valid date format") unless daily_actual.date

      if errors[:price].any?
        errors.delete(:price).each { |error| errors.add('eCPM', error) }
      end

      if errors[:revenue_loc].any?
        errors.delete(:revenue_loc).each { |error| errors.add(:Revenue, error) }
      end
    end

    daily_actual.errors.empty?
  end
end
