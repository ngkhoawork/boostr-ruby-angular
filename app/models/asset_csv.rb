require 'chronic'

class AssetCsv
  include ActiveModel::Validations

  validates :original_file_name, :attachable_id, :attachable_type,
            :company_id, presence: true

  validate do |asset_csv|
    asset_csv.errors.add(:asset, "with name #{asset_csv.original_file_name} not found or is already mapped") if asset.blank?
  end

  validate do |asset_csv|
    if asset_csv.uploader_email.present? && creator.blank?
      asset_csv.errors.add(:base, "Can't find user with email #{asset_csv.uploader_email}")
    end
  end

  validate do |asset_csv|
    if asset_csv.attachable_type.present? && !attachable_type_valid?
      asset_csv.errors.add(:attachable_type, "#{asset_csv.attachable_type} does not exist")
    end
  end

  validate do |asset_csv|
    if attachable_type_valid? && !attachable_exists?
      asset_csv.errors.add(:base, "Can't find #{asset_csv.attachable_type} with ID #{asset_csv.attachable_id}")
    end
  end

  attr_accessor(:original_file_name, :attachable_id, :attachable_type,
    :created_at, :company_id, :uploader_email)
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    return self.errors.full_messages unless self.valid?

    if asset.present?
      asset.update(
        attachable_id: attachable_id,
        attachable_type: attachable_type,
        created_at: parsed_created_at,
        created_by: creator.try(:id)
      )
    end
  end

  def self.import(file, current_user_id, file_path)
    current_user = User.find current_user_id
    company_id = current_user.company_id

    import_log = CsvImportLog.new(company_id: company_id, object_name: 'asset', source: 'ui')
    import_log.set_file_source(file_path)

    CSV.parse(file, { headers: true, header_converters: :symbol }) do |row|
      import_log.count_processed

      asset = self.build_asset(row, company_id)
      if asset.valid?
        begin
          asset.perform
          import_log.count_imported
        rescue Exception => e
          import_log.count_failed
          import_log.log_error ['Internal Server Error', row.to_h.compact.to_s, e.class]
          next
        end
      else
        import_log.count_failed
        import_log.log_error asset.errors.full_messages
        next
      end
    end

    import_log.save
  end

  private

  def asset
    @_asset ||= Asset.for_company(self.company_id).unmapped.where(original_file_name: original_file_name).last
  end

  def attachable_exists?
    attachable_type.constantize.exists?(id: attachable_id)
  end

  def attachable_type_valid?
    %w(Deal Activity Contract).include?(self.attachable_type)
  end

  def creator
    @_creator ||= User.where(company_id: company_id).by_email(uploader_email).first
  end

  def persisted?
    false
  end

  def self.build_asset(row, company_id)
    AssetCsv.new(
      original_file_name: row[:file_name],
      attachable_id: row[:object_id],
      attachable_type: row[:object_type],
      created_at: row[:created_at],
      uploader_email: row[:uploader_email],
      company_id: company_id
    )
  end

  def parsed_created_at
    Chronic.parse(self.created_at) || asset.created_at
  end
end
