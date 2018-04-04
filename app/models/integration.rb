class Integration < ActiveRecord::Base
  OPERATIVE = 'operative'.freeze
  OPERATIVE_DATAFEED = 'Operative Datafeed'.freeze
  DFP = 'DFP'.freeze
  ASANA_CONNECT = 'Asana Connect'.freeze
  GOOGLE_SHEETS = 'Google Sheets'.freeze
  SSP = 'SSP'.freeze
  SLACK = 'Slack'.freeze

  validates :external_id, :external_type, presence: true

  belongs_to :integratable, polymorphic: true

  scope :operative, -> { find_by(external_type: OPERATIVE) }

  def self.get_types(current_user)
    integration_types = [
      OPERATIVE, OPERATIVE_DATAFEED, DFP, ASANA_CONNECT, SSP
    ]
    integration_types << GOOGLE_SHEETS if current_user.company.buzzfeed?
    integration_types
  end

  def self.import(file, current_user_id, file_path)
    current_user = User.find current_user_id

    import_log = CsvImportLog.new(company_id: current_user.company_id, object_name: 'integration', source: 'ui')
    import_log.set_file_source(file_path)

    CSV.parse(file, headers: true) do |row|
      import_log.count_processed
      integration_params = {}

      if row[0]
        integration_params[:integratable_type] = row[0].strip
      else
        import_log.count_failed
        import_log.log_error(["Type can't be blank"])
        next
      end

      if row[1]
        integration_params[:external_id] = row[1].strip
      else
        import_log.count_failed
        import_log.log_error(["External ID can't be blank"])
        next
      end

      if row[2]
        integration_params[:external_type] = row[2].strip
      else
        import_log.count_failed
        import_log.log_error(["External Type can't be blank"])
        next
      end

      if row[3]
        case row[0].strip
        when 'Client'
          target = current_user.company.clients.find_by(name: row[3].strip)
        when 'Deal'
          target = current_user.company.deals.find_by(name: row[3].strip)
        when 'Contact'
          target = current_user.company.contacts.find_by(name: row[3].strip)
        end
        if target.nil?
          import_log.count_failed
          import_log.log_error(["#{row[0].strip} name #{row[3].strip} did not match any #{row[0].strip} record"])
          next
        else
          integration_params[:integratable_id] = target.id
        end
      end

      if row[4] && integration_params[:integratable_id].nil?
        case row[0].strip
        when 'Client'
          target = current_user.company.clients.find_by(id: row[4].strip)
        when 'Deal'
          target = current_user.company.deals.find_by(id: row[4].strip)
        when 'Contact'
          target = current_user.company.contacts.find_by(id: row[4].strip)
        end
        if target.nil?
          import_log.count_failed
          import_log.log_error(["#{row[0].strip} ID #{row[4].strip} did not match any #{row[0].strip} record"])
          next
        else
          integration_params[:integratable_id] = target.id
        end
      end

      if integration_params[:integratable_id].nil?
        import_log.count_failed
        import_log.log_error(["Related Name or Related ID is not valid"])
        next
      end

      integration_row = Integration.find_or_initialize_by(integration_params)

      if integration_row.save
        import_log.count_imported
      else
        import_log.count_failed
        import_log.log_error(integration_row.errors.full_messages)
        next
      end
    end

    import_log.save
  end
end
