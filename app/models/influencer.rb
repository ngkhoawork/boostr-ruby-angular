class Influencer < ActiveRecord::Base
  belongs_to :company
  has_one :agreement, dependent: :destroy
  has_many :values, as: :subject
  has_many :influencer_content_fees
  has_one :address, as: :addressable

  accepts_nested_attributes_for :agreement
  accepts_nested_attributes_for :values
  accepts_nested_attributes_for :address

  scope :by_name, -> name { where('influencers.name ilike ?', "%#{name}%") if name.present? }

  def fields
    company.fields.where(subject_type: self.class.name)
  end

  def network_name
    subject_fields = fields
    if !subject_fields.nil?
      field = subject_fields.find_by_name('Network')
      value = values.find_by_field_id(field.id) if !field.nil?
      option = value.option.name if !value.nil? && !value.option.nil?
    end
    option
  end

  def self.import(file, current_user_id, file_path)
    current_user = User.find current_user_id

    network_field = current_user.company.fields.find_by_name('Network')

    import_log = CsvImportLog.new(company_id: current_user.company_id, object_name: 'influencer', source: 'ui')
    import_log.set_file_source(file_path)

    CSV.parse(file, headers: true, header_converters: :symbol) do |row|
      import_log.count_processed

      # influencer id
      if row[0].present?
        begin
          influencer = current_user.company.influencers.find(row[0].strip)
        rescue ActiveRecord::RecordNotFound
          import_log.count_failed
          import_log.log_error(["Influencer ID #{row[0]} could not be found"])
          next
        end
      end

      # influencer name
      if row[1].nil? || row[1].blank?
        import_log.count_failed
        import_log.log_error(["Influencer name can't be blank"])
        next
      end

      # network
      network = nil
      if row[2].present?
        network = network_field.options.where('name ilike ?', row[2].strip).first
        unless network
          import_log.count_failed
          import_log.log_error(["Network #{row[2]} could not be found"])
          next
        end
      end

      # agreement type
      agreement_type = nil
      if row[3].present? 
        if ['flat', 'percentage'].include?(row[3].strip.downcase)
          agreement_type = row[3].strip
        else
          import_log.count_failed
          import_log.log_error(["Agreement type must be 'flat' or 'percentage'"])
          next
        end
      end

      # agreement fee
      if row[4].present? 
        agreement_fee = row[4].to_f
      else
        agreement_fee = nil
      end

      # email
      email = nil
      if row[5].present?
        if row[5].match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/).present?
          email = row[5].strip
        else
          import_log.count_failed
          import_log.log_error(["Email must be valid"])
          next
        end
      end

      influencer_params = {
        name: row[1].strip,
        phone: row[6].strip,
        email: email
      }

      address_params = {
        email: email,
        street1: row[7].nil? ? nil : row[7].strip,
        city: row[8].nil? ? nil : row[8].strip,
        state: row[9].nil? ? nil : row[9].strip,
        country: row[10].nil? ? nil : row[10].strip,
        zip: row[11].nil? ? nil : row[11].strip,
        phone: row[6].nil? ? nil : row[6].strip
      }

      agreement_params = {
        fee_type: agreement_type, 
        amount: agreement_fee
      }

      network_value_params = {
        value_type: 'Option',
        subject_type: 'Influencer',
        field_id: network_field.id,
        option_id: (network ? network.id : nil),
        company_id: current_user.company.id
      }

      if influencer.present?
        network_value_params[:subject_id] = influencer.id
        if network_value = influencer.values.where(field_id: network_field).first
          network_value_params[:id] = network_value.id
        end
        address_params[:id] = influencer.address.id
        agreement_params[:id] = influencer.agreement.id
      else
        influencer = current_user.company.influencers.new
      end

      influencer_params[:values_attributes] = [
        network_value_params
      ]
      influencer_params[:address_attributes] = address_params
      influencer_params[:agreement_attributes] = agreement_params

      if influencer.update_attributes(influencer_params)
        import_log.count_imported
      else
        import_log.count_failed
        import_log.log_error(influencer.errors.full_messages)
        next
      end
    end

    import_log.save
  end

  def self.to_csv(company, influencers)
    header = [
      'Id',
      'Name',
      'Network',
      'Agreement Type',
      'Agreement Fee',
      'Email',
      'Phone',
      'Street',
      'City',
      'State',
      'Country',
      'Postal Code'
    ]
    network_field = company.fields.find_by_name('Network')

    CSV.generate(headers: true) do |csv|
      csv << header
      influencers = influencers.includes(:agreement, values: :option)
      influencers.each do |influencer|
        line = []
        line << influencer.id
        line << influencer.name
        line << influencer.values.find{ |value| value.field_id == network_field.id }.try(:option).try(:name)
        line << influencer.agreement.fee_type
        line << influencer.agreement.amount
        line << influencer.email
        line << influencer.phone
        line << (influencer.address.nil? ? nil : influencer.address.street1)
        line << (influencer.address.nil? ? nil : influencer.address.city)
        line << (influencer.address.nil? ? nil : influencer.address.state)
        line << (influencer.address.nil? ? nil : influencer.address.country)
        line << (influencer.address.nil? ? nil : influencer.address.zip)
        csv << line
      end
    end
  end
end
