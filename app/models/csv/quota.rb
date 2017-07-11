class Csv::Quota
  include ActiveModel::Validations

  attr_accessor :time_period_id, :user_id, :value

  validates :time_period_id, :user_id, :value, presence: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def self.import(file, user_id, file_path)
    user = User.find(user_id)
    company = user.company

    import_log = CsvImportLog.new(company_id: company.id, object_name: 'quota', source: 'ui')
    import_log.set_file_source(file_path)

    CSV.foreach(file, headers: true) do |row|
      time_period = company.time_periods.find_by(name: row['Time Period'])
      user = company.users.find_by(email: row['Email'])
      csv_quota = self.build_csv_quota(row, time_period.id, user_id)
      quota = company.quotas.find_by(time_period_id: time_period.id, user_id: user.id)

      if csv_quota.valid?
        begin
          csv_quota.save(row, company, quota, time_period.id, user.id)
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

      import_log.save
    end
  end

  def self.build_csv_quota(row, time_period_id, user_id)
    Csv::Quota.new(
      time_period_id: time_period_id,
      user_id: user_id,
      value: row['Quota']
    )
  end

  def save(row, company, quota, time_period_id, user_id)
    if quota.present?
      quota.update(value: row['Quota'])
    else
      company.quotas.create(
        time_period_id: time_period_id,
        user_id: user_id,
        value: row['Quota']
      )
    end
  end

  def persisted?
    false
  end
end
