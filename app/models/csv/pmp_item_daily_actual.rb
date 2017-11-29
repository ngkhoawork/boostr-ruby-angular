require 'chronic'

class Csv::PmpItemDailyActual
  include ActiveModel::Validations

  validates :ssp_deal_id,
            :date,
            :ad_unit,
            :bids,
            :impressions,
            :win_rate,
            :ecpm,
            :revenue_loc,
            :currency, presence: true
  
  validates :bids, numericality: true
  validates :impressions, numericality: true
  validates :win_rate, numericality: true
  validates :ecpm, numericality: true
  validates :revenue, numericality: true
  
  validate  :validate_pmp_item_presence
  validate  :validate_date_format

  attr_accessor(
    :ssp_deal_id,
    :date,
    :ad_unit,
    :bids,
    :impressions,
    :win_rate,
    :ecpm,
    :revenue_loc,
    :currency
  )
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def save
    if pmp_item_daily_actual.present?
      pmp_item_daily_actual.update(
        ad_unit: ad_unit,
        bids: bids,
        impressions: impressions,
        win_rate: win_rate,
        price: ecpm,
        revenue_loc: revenue_loc,
        revenue: revenue
      )
    else
      PmpItemDailyActual.create({
        pmp_item_id: pmp_item.id,
        date: parsed_date,
        ad_unit: ad_unit,
        bids: bids,
        impressions: impressions,
        win_rate: win_rate,
        price: ecpm,
        revenue_loc: revenue_loc,
        revenue: revenue
      })
    end
  end

  def self.import(file, current_user_id, file_path)
    current_user = User.find current_user_id
    company = current_user.company

    import_log = CsvImportLog.new(company_id: company.id, object_name: 'pmp_item_daily_actual', source: 'ui')
    import_log.set_file_source(file_path)

    CSV.parse(file, { headers: true, header_converters: :symbol }) do |row|
      import_log.count_processed

      csv_pmp_item_daily_actual = self.build(row, company)
      if csv_pmp_item_daily_actual.valid?
        begin
          csv_pmp_item_daily_actual.save
          import_log.count_imported
        rescue Exception => e
          import_log.count_failed
          import_log.log_error ['Internal Server Error', row.to_h.compact.to_s, e.class]
          next
        end
      else
        import_log.count_failed
        import_log.log_error csv_pmp_item_daily_actual.errors.full_messages
        next
      end
    end

    import_log.save
  end

  private

  def validate_pmp_item_presence
    errors.add(:pmp_item, "with Deal-Id #{ssp_deal_id} could not be found") if pmp_item.blank?
  end

  def validate_date_format
    errors.add(:date, "- #{date} must be a valid datetime") unless date_valid?
  end

  def pmp_item
    @_pmp_item ||= PmpItem.find_by(ssp_deal_id: ssp_deal_id)
  end

  def pmp_item_daily_actual
    @_pmp_item_daily_actual ||= if pmp_item.present?
      PmpItemDailyActual.find_by(pmp_item_id: pmp_item.id, date: parsed_date)
    else
      nil
    end
  end

  def revenue
    @_revenue ||= revenue_loc
  end

  def parsed_date
    @_parsed_date ||= if date.present?
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

  def self.build(row, company)
    Csv::PmpItemDailyActual.new(
      ssp_deal_id: row[:dealid],
      date: row[:date].try(:strip),
      ad_unit: row[:ad_unit],
      bids: row[:bids],
      impressions: row[:impressions],
      win_rate: row[:win_rate],
      ecpm: row[:ecpm],
      revenue_loc: row[:revenue],
      currency: row[:currency]
    )
  end
end
