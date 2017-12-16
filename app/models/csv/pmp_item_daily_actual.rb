require 'chronic'

class Csv::PmpItemDailyActual
  include ActiveModel::Validations

  attr_accessor :ssp_deal_id,
                :date,
                :ad_unit,
                :bids,
                :impressions,
                :price,
                :revenue_loc,
                :render_rate,
                :win_rate,
                :curr_cd

  validate :validate_pmp_item_presence
  validate :validate_deal_id
  validate :validate_date_format
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def valid?
    prepare_pmp_item_daily_actual
    pmp_item_daily_actual.valid? & super
  end

  def error_messages
    keys = errors.messages.keys + pmp_item_daily_actual.errors.messages.keys
    keys.uniq.map do |attr| 
      if attr == :base
        errors.full_messages_for(attr) + pmp_item_daily_actual.errors.full_messages_for(attr)
      elsif attr == :pmp_item
        errors.full_messages_for(attr).try(:first)
      else
        errors.full_messages_for(attr).try(:first) || pmp_item_daily_actual.errors.full_messages_for(attr).try(:first)
      end
    end.flatten.compact
  end

  def save
    prepare_pmp_item_daily_actual
    pmp_item_daily_actual.save!
  end

  def pmp_item
    @_pmp_item ||= PmpItem.find_by(ssp_deal_id: ssp_deal_id)
  end

  def pmp_item_daily_actual
    @_pmp_item_daily_actual ||= if pmp_item.present?
      ::PmpItemDailyActual.find_or_initialize_by(pmp_item_id: pmp_item.id, date: parsed_date, product_id: product.try(:id))
    else
      ::PmpItemDailyActual.new
    end
  end

  def self.import(file, current_user_id, file_path)
    company = User.find(current_user_id).try(:company)
    return unless company.present?

    pmp_item_ids = []
    pmp_ids = []
    import_log = CsvImportLog.new(company_id: company.id, object_name: 'pmp_item_daily_actual', source: 'ui')
    import_log.set_file_source(file_path)

    CSV.parse(file, { headers: true, header_converters: :symbol }) do |row|
      import_log.count_processed

      csv_pmp_item_daily_actual = self.build(row, company)
      if csv_pmp_item_daily_actual.valid?
        begin
          pmp_item_ids << csv_pmp_item_daily_actual.pmp_item.id
          pmp_ids << csv_pmp_item_daily_actual.pmp_item.pmp.id
          csv_pmp_item_daily_actual.save
          import_log.count_imported
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
  end

  private

  def validate_pmp_item_presence
    errors.add(:pmp_item, "with Deal-Id #{ssp_deal_id} could not be found") if pmp_item.nil? && !ssp_deal_id.blank?
  end

  def validate_date_format
    errors.add(:date, "- #{date} must be in valid date format") unless date_valid?
  end

  def validate_deal_id
    errors.add(:base, "Deal-ID can't be blank") if ssp_deal_id.blank?
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

  def prepare_pmp_item_daily_actual
    pmp_item_daily_actual.date = parsed_date
    pmp_item_daily_actual.ad_unit = ad_unit
    pmp_item_daily_actual.pmp_item = pmp_item
    pmp_item_daily_actual.bids = bids
    pmp_item_daily_actual.impressions = impressions
    pmp_item_daily_actual.win_rate = win_rate
    pmp_item_daily_actual.price = price
    pmp_item_daily_actual.revenue_loc = revenue_loc
    pmp_item_daily_actual.render_rate = render_rate
    pmp_item_daily_actual.imported = true
    pmp_item_daily_actual.product = product
  end

  def self.build(row, company)
    Csv::PmpItemDailyActual.new(
      ssp_deal_id: row[:dealid],
      date: row[:date].try(:strip),
      ad_unit: row[:ad_unit],
      bids: row[:bids],
      impressions: row[:impressions],
      win_rate: row[:win_rate],
      price: row[:ecpm],
      revenue_loc: row[:revenue],
      curr_cd: row[:currency],
      render_rate: row[:render_rate]
    )
  end
end
