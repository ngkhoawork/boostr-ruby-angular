require 'chronic'

class Csv::InfluencerContentFee
  include ActiveModel::Validations

  validates :io_number, :influencer_id, :product_name, :date, :gross_amount_loc, :company, presence: true
  validates :fee_amount, numericality: true

  validate do |csv|
    csv.errors.add(:io, "with id #{io_number} could not be found") if io.blank?
  end

  validate do |csv|
    csv.errors.add(:influencer, "with id #{influencer_id} could not be found") if influencer.blank?
  end

  validate do |csv|
    csv.errors.add(:product, "with name #{product_name} could not be found") if product.blank?
  end

  validate do |csv|
    if date_valid?
      csv.errors.add(:date, 'must be between IO start and end dates') unless date_in_io_range?
    else
      csv.errors.add(:date, 'must be a valid datetime')
    end
  end

  validate do |csv|
    csv.errors.add(:fee_type, 'should be either \'percentage\' or \'flat\'') unless fee_type_valid?
  end

  validate do |csv|
    csv.errors.add(:base, 'Content fee for specified io and product could not be found') if content_fee.blank?
  end

  attr_accessor(:io_number, :influencer_id, :product_name, :date, :fee_type, :fee_amount, :gross_amount_loc, :asset, :company)
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    InfluencerContentFee.create({
      influencer_id: influencer_id,
      content_fee_id: content_fee.id,
      fee_type: get_fee_type,
      fee_amount: get_fee_amount,
      effect_date: effect_date,
      curr_cd: io.curr_cd,
      gross_amount_loc: gross_amount_loc,
      asset: asset
    })
    io.update_influencer_budget
  end

  def self.import(file, current_user_id, file_path)
    current_user = User.find current_user_id
    company = current_user.company

    import_log = CsvImportLog.new(company_id: company.id, object_name: 'influencer_content_fee', source: 'ui')
    import_log.set_file_source(file_path)

    CSV.parse(file, { headers: true, header_converters: :symbol }) do |row|
      import_log.count_processed

      influencer_content_fee = self.build(row, company)
      if influencer_content_fee.valid?
        begin
          influencer_content_fee.perform
          import_log.count_imported
        rescue Exception => e
          import_log.count_failed
          import_log.log_error ['Internal Server Error', row.to_h.compact.to_s, e.class]
          next
        end
      else
        import_log.count_failed
        import_log.log_error influencer_content_fee.errors.full_messages
        next
      end
    end

    import_log.save
  end

  private

  def get_fee_type
    if influencer.agreement.present? && fee_type.blank?
      fee_type = influencer.agreement.fee_type
    end
    fee_type
  end

  def get_fee_amount
    if influencer.agreement.present? && fee_amount.blank?
      fee_amount = influencer.agreement.amount
    end
    if fee_type == 'flat' && io.exchange_rate.present?
      fee_amount = (fee_amount.to_f * io.exchange_rate).round(2)
    end
    fee_amount
  end

  def effect_date
    d = Date.strptime(date, "%m/%d/%Y")
    if d.year < 100
      d = Date.strptime(date, "%m/%d/%y")
    end
    d
  end

  def io
    @_io ||= company.ios.find_by(io_number: io_number)
  end

  def influencer
    @_influencer ||= company.influencers.find_by(id: influencer_id)
  end

  def product
    @_product ||= io.content_fee_products.find_by(name: product_name)
  end

  def content_fee
    @_content_fee = io.content_fees.find_by(product_id: product.id)
  end

  def fee_type_valid?
    fee_type.downcase == 'percentage' || fee_type.downcase == 'flat'
  end

  def date_valid?
    begin
      Date.strptime(date, "%m/%d/%Y")
    rescue ArgumentError
      return false
    end
    return true
  end

  def date_in_io_range?
    effect_date = Date.strptime(date, "%m/%d/%Y")
    if effect_date && !(effect_date >=io.start_date && effect_date <= io.end_date)
      return false
    end
    return true
  end

  def self.build(row, company)
    Csv::InfluencerContentFee.new(
      io_number: row[:io_num],
      influencer_id: row[:influence_id],
      product_name: row[:product],
      date: row[:date].strip,
      fee_type: row[:fee_type],
      fee_amount: row[:fee_amt].to_f,
      gross_amount_loc: row[:gross],
      asset: row[:asset].strip,
      company: company
    )
  end
end
