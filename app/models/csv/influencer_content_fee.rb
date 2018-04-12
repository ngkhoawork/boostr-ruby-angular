require 'chronic'

class Csv::InfluencerContentFee
  include ActiveModel::Validations
  include Csv::ProductOptionable

  validates :io_number, :influencer_id, :product_name, :date, :gross_amount_loc, :company, :fee_type, presence: true
  validates :fee_amount, numericality: true

  validate :validate_io_presence
  validate :validate_influencer_presence
  validate :validate_product_presence
  validate :validate_date_format
  validate :validate_date_inclusion
  validate :validate_fee_type
  validate :validate_content_fee_presence

  attr_accessor :io_number, 
                :influencer_id, 
                :product_name, 
                :product_level1, 
                :product_level2, 
                :date, 
                :fee_type, 
                :fee_amount, 
                :gross_amount_loc, 
                :asset, 
                :company
  
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

  def validate_io_presence
    errors.add(:io, "with id #{io_number} could not be found") if io.blank?
  end

  def validate_influencer_presence
    errors.add(:influencer, "with id #{influencer_id} could not be found") if influencer.blank?
  end

  def validate_product_presence
    errors.add(:product, "with name #{product_full_name} could not be found") if product.blank?
  end

  def validate_date_format
      errors.add(:date, "- #{date} must be a valid datetime") unless date_valid?
  end

  def validate_date_inclusion
    errors.add(:date, "- #{date} must be between IO start and end dates") unless date_in_io_range?
  end

  def validate_fee_type
    errors.add(:fee_type, "- #{fee_type} should be either 'percentage' or 'flat'") unless fee_type_valid?
  end

  def validate_content_fee_presence
    errors.add(:content_fee, "for specified io #{io_number} and product #{product_full_name} could not be found") if content_fee.blank?
  end

  def get_fee_type
    if influencer.agreement.present? && fee_type.blank?
      self.fee_type = influencer.agreement.fee_type
    end
    self.fee_type
  end

  def get_fee_amount
    if influencer.agreement.present? && fee_amount.blank?
      self.fee_amount = influencer.agreement.amount
    end
    if fee_type == 'flat' && io.exchange_rate.present?
      self.fee_amount = (fee_amount.to_f * io.exchange_rate).round(2)
    end
    self.fee_amount
  end

  def effect_date
    d = Date.strptime(date, "%m/%d/%Y") if date.present?
    if d && d.year < 100
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
    @_product ||= io.content_fee_products.find_by(full_name: product_full_name) if io.present?
  end

  def content_fee
    @_content_fee = io.content_fees.find_by(product_id: product.id) if io.present? && product.present?
  end

  def fee_type_valid?
    fee_type.present? && (fee_type.downcase == 'percentage' || fee_type.downcase == 'flat')
  end

  def date_valid?
    begin
      Date.strptime(date, "%m/%d/%Y") if date.present?
    rescue ArgumentError
      return false
    end
    return true
  end

  def date_in_io_range?
    if effect_date && !(effect_date >=io.start_date && effect_date <= io.end_date)
      return false
    end
    return true
  end

  def self.build(row, company)
    Csv::InfluencerContentFee.new(
      io_number: row[:io_num],
      influencer_id: row[:influencer_id],
      product_name: row[:product],
      product_level1: row[:product_level1],
      product_level2: row[:product_level2],
      date: row[:date].try(:strip),
      fee_type: row[:fee_type],
      fee_amount: row[:fee_amt].to_f,
      gross_amount_loc: row[:gross],
      asset: row[:asset].try(:strip),
      company: company
    )
  end
end
