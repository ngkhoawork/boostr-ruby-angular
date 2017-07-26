class Csv::Quota
  include ActiveModel::Validations

  attr_accessor :time_period_name, :user_email, :quota_value, :company

  validates :time_period_name, :user_email, :quota_value, :company, presence: true

  validate do |quota_csv|
    if time_period.nil?
      quota_csv.errors.add(:base, "Time period with --#{time_period_name}-- name doesn't exist")
    end
  end

  validate do |quota_csv|
    if user.nil?
      quota_csv.errors.add(:base, "User with --#{user_email}-- email doesn't exist")
    end
  end

  validate do |quota_csv|
    if quota_value.match(/^\d+$/).blank?
      quota_csv.errors.add(:base, 'Quota should has numeric value.')
    end
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def self.import(file, current_user_id, file_path)
    current_user = User.find(current_user_id)
    company = current_user.company

    import_log = CsvImportLog.new(company_id: company.id, object_name: 'quota', source: 'ui')
    import_log.set_file_source(file_path)

    CSV.parse(file, headers: true, header_converters: :symbol) do |row|
      import_log.count_processed

      begin
        csv_quota = self.build_quota(row, company)

        if csv_quota.valid?
          csv_quota.save(company)
          import_log.count_imported
        else
          import_log.count_failed
          import_log.log_error csv_quota.errors.full_messages
          next
        end
      rescue Exception => e
        import_log.count_failed
        import_log.log_error ['Internal Server Error', row.to_h.compact.to_s, e.class]
        next
      end
    end

    import_log.save
  end

  def self.build_quota(row, company)
    Csv::Quota.new(
      time_period_name: row[:time_period],
      user_email: row[:email],
      quota_value: row[:quota],
      company: company
    )
  end

  def save(company)
    if quota.present?
      quota.update(value: quota_value)
    else
      company.quotas.create(
        time_period_id: time_period.id,
        user_id: user.id,
        value: quota_value
      )
    end
  end

  def time_period
    @_time_period ||= company.time_periods.find_by(name: time_period_name)
  end

  def user
    @_user = company.users.find_by(email: user_email)
  end

  def quota
    @_quota = company.quotas.find_by(time_period_id: time_period.id, user_id: user.id)
  end

  def persisted?
    false
  end
end
