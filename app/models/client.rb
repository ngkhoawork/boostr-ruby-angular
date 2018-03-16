class Client < ActiveRecord::Base
  include PgSearch
  acts_as_paranoid

  belongs_to :company
  belongs_to :parent_client, class_name: 'Client'

  has_many :child_clients, class_name: 'Client', foreign_key: :parent_client_id
  has_many :client_members
  has_many :users, through: :client_members
  has_many :client_member_info, -> { joins(:user).select(:id, :client_id, :share, 'users.first_name', 'users.last_name') }, class_name: 'ClientMember'
  has_many :contacts, -> { uniq }, through: :client_contacts
  has_many :primary_client_contacts, -> { where('client_contacts.primary = ?', true) }, class_name: 'ClientContact'
  has_many :primary_contacts, -> { uniq }, through: :primary_client_contacts, source: :contact
  has_many :secondary_client_contacts, -> { where('client_contacts.primary = ?', false) }, class_name: 'ClientContact'
  has_many :secondary_contacts, -> { uniq }, through: :secondary_client_contacts, source: :contact
  has_many :client_contacts, dependent: :destroy
  has_many :revenues
  has_many :agency_deals, class_name: 'Deal', foreign_key: 'agency_id', dependent: :nullify
  has_many :advertiser_deals, class_name: 'Deal', foreign_key: 'advertiser_id', dependent: :nullify
  has_many :open_advertiser_deals, -> { joins(:stage).where('stages.open IS true') }, class_name: 'Deal', foreign_key: 'advertiser_id'

  has_many :agency_ios, class_name: 'Io', foreign_key: 'agency_id'
  has_many :advertiser_ios, class_name: 'Io', foreign_key: 'advertiser_id'
  has_many :bp_estimates

  has_many :agency_connections, class_name: :ClientConnection,
           foreign_key: :agency_id, dependent: :destroy
  has_many :advertiser_connections, class_name: :ClientConnection,
           foreign_key: :advertiser_id, dependent: :destroy
  has_many :agencies, -> { uniq }, through: :advertiser_connections, source: :agency
  has_many :advertisers, -> { uniq }, through: :agency_connections, source: :advertiser

  has_many :agency_client_contacts, through: :agencies, source: :client_contacts
  has_many :advertiser_client_contacts, -> { uniq }, through: :advertisers, source: :primary_client_contacts

  has_many :agency_contacts, through: :agencies, source: :contacts
  has_many :advertiser_contacts, -> { uniq }, through: :advertisers, source: :primary_contacts

  has_many :advertiser_contracts, class_name: 'Contract', foreign_key: :advertiser_id, dependent: :nullify
  has_many :agency_contracts, class_name: 'Contract', foreign_key: :agency_id, dependent: :nullify

  has_many :values, as: :subject
  has_many :activities, -> { order(happened_at: :desc) }
  has_many :agency_activities, -> { order(happened_at: :desc) }, class_name: 'Activity', foreign_key: 'agency_id'
  has_many :reminders, as: :remindable, dependent: :destroy
  has_many :account_dimensions, foreign_key: 'id', dependent: :destroy
  has_many :integrations, as: :integratable

  has_many :ssp_advertisers

  has_one :latest_advertiser_activity, -> { self.select_values = ["DISTINCT ON(activities.client_id) activities.*"]
    order('activities.client_id', 'activities.happened_at DESC')
  }, class_name: 'Activity'
  has_one :latest_agency_activity, -> { self.select_values = ["DISTINCT ON(activities.agency_id) activities.*"]
    order('activities.agency_id', 'activities.happened_at DESC')
  }, class_name: 'Activity'

  has_one :account_cf, dependent: :destroy
  has_one :primary_client_member, -> { order(share: :desc) }, class_name: 'ClientMember'
  has_one :primary_user, through: :primary_client_member, source: :user
  has_one :address, as: :addressable
  has_one :publisher

  belongs_to :client_category, class_name: 'Option', foreign_key: 'client_category_id'
  belongs_to :client_subcategory, class_name: 'Option', foreign_key: 'client_subcategory_id'
  belongs_to :client_region, class_name: 'Option', foreign_key: 'client_region_id'
  belongs_to :client_segment, class_name: 'Option', foreign_key: 'client_segment_id'
  belongs_to :holding_company

  delegate :street1, :street2, :city, :state, :zip, :phone, :country, to: :address, allow_nil: true
  delegate :name, to: :client_category, prefix: :category, allow_nil: true
  delegate :name, to: :parent_client, prefix: true, allow_nil: true

  accepts_nested_attributes_for :address, :values
  accepts_nested_attributes_for :account_cf

  validates :name, :client_type_id, presence: true
  validate  :base_fields_presence

  before_create :ensure_client_member
  after_commit :update_account_dimension, on: [:create, :update]

  pg_search_scope :search_by_name,
                  against: :name,
                  using: {
                    tsearch: {
                      dictionary: :english,
                      prefix: true,
                      any_word: true
                    },
                    dmetaphone: {
                      any_word: true
                    }
                  },
                  ranked_by: ':trigram'

  scope :by_type_id, -> type_id { where(client_type_id: type_id) if type_id.present? }
  scope :opposite_type_id, -> type_id { where.not(client_type_id: type_id) if type_id.present? }
  scope :exclude_ids, -> ids { where.not(id: ids) }
  scope :by_contact_ids, -> ids { Client.joins("INNER JOIN client_contacts ON clients.id=client_contacts.client_id").where("client_contacts.contact_id in (:q)", {q: ids}).order(:name).distinct }
  scope :by_category, -> category_id { where(client_category_id: category_id) if category_id.present? }
  scope :by_subcategory, -> subcategory_id { where(client_subcategory_id: subcategory_id) if subcategory_id.present? }
  scope :by_region, -> region_id { where(client_region_id: region_id) if region_id.present? }
  scope :by_segment, -> segment_id { where(client_segment_id: segment_id) if segment_id.present? }
  scope :by_name, -> name { where('clients.name ilike ?', "%#{name}%") if name.present? }
  scope :by_name_and_type_with_limit, -> (name, type) { by_name(name).by_type_id(type).limit(20) }
  scope :by_city, -> city { Client.joins("INNER JOIN addresses ON clients.id = addresses.addressable_id AND addresses.addressable_type = 'Client'").where("addresses.city = ?", city) if city.present? }
  scope :by_ids, -> ids { where(id: ids) if ids.present?}
  scope :by_last_touch, -> (start_date, end_date) { Client.joins("INNER JOIN (select client_id, max(happened_at) as last_touch from activities group by client_id) as tb1 ON clients.id = tb1.client_id").where("tb1.last_touch >= ? and tb1.last_touch <= ?", start_date, end_date) if start_date.present? && end_date.present? }
  scope :excepting_client_associations, ->(client, assoc_name) do
    send("without_#{assoc_name}_for", client) if %i(child_clients connections).include?(assoc_name.to_sym)
  end
  scope :without_child_clients_for, ->(client) { where.not(id: client.child_client_ids) }
  scope :without_connections_for, ->(client) { where.not(id: client.connection_entry_ids) }
  scope :without_related_clients, -> contact_id do
    where.not(id: ClientContact.where(contact_id: contact_id).pluck(:client_id))
  end
  
  pg_search_scope :fuzzy_search,
                  against: :name,
                  using: {
                    tsearch: {
                      prefix: true,
                      any_word: true
                    },
                    dmetaphone: {
                      any_word: true
                    }
                  },
                  ranked_by: ':trigram'

  ADVERTISER = 10
  AGENCY = 11

  def self.to_csv(company)
    Csv::AccountsService.new(self, company).perform
  end

  def connection_entry_ids
    case client_type.name
    when 'Agency'
      agency_connections.pluck(:advertiser_id)
    when 'Advertiser'
      advertiser_connections.pluck(:agency_id)
    else
      raise "callable for ['Advertiser', 'Agency'] clients only"
    end
  end

  def update_account_dimension
    AccountDimensionUpdaterService.new(client: self).perform
  end

  def advertiser?
    is_advertiser = false
    values.each do |value|
      if value.field.name == "Client Type" and value.option.name == "Advertiser"
        is_advertiser = true
        break
      end
    end
    is_advertiser
  end

  def agency?
    is_agency = false
    values.each do |value|
      if value.field.name == "Client Type" and value.option.name == "Agency"
        is_agency = true
        break
      end
    end
    is_agency
  end

  def max_share_user
    users.merge(ClientMember.ordered_by_share_desc).first
  end

  def deals_count
    advertiser_deals_count + agency_deals_count
  end

  def fields
    company.fields.where(subject_type: self.class.name)
  end

  def formatted_name
    f_name = name
    if !address.nil?
      if !address.city.nil?
        f_name = f_name + ', '+ address.city.to_s
      end
      if !address.state.nil?
        f_name = f_name + ', '+ address.state.to_s
      end
    end
    f_name
  end

  def as_json(options = {})
    if options[:override]
      super(options)
    else
      super(options.deep_merge(
        include: {
          address: {},
          parent_client: { only: [:id, :name] },
          account_cf: {},
          holding_company: {},
          values: {
            methods: [:value],
            include: [:option]
          },
          client_members: {
                  include: {
                          user: {
                                  only: [:id],
                                  methods: [:name]
                          }
                  },
                  only: [:id, :share, :user_id, :role]
          },
          activities: {
            include: {
              creator: {},
              publisher: { only: [:id, :name] },
              contacts: {},
              assets: {
                methods: [
                  :presigned_url
                ]
              },
              activity_type: { only: [:id, :name, :css_class, :action] }
            }
          },
          agency_activities: {
            include: {
              creator: {},
              contacts: {},
              publisher: { only: [:id, :name] },
              assets: {
                methods: [
                  :presigned_url
                ]
              },
              activity_type: { only: [:id, :name, :css_class, :action] }
            }
          },
          ssp_advertisers: {
            include: {
              ssp: {}
            }
          }
        },
        methods: [:deals_count, :fields, :formatted_name]
      ).except(:override))
    end
  end

  def ensure_client_member
    return true if created_by.blank?
    return true if client_members.detect { |member| member.user_id == created_by }

    share = 0
    if advertiser?
      share = 100
    end
    client_members.build(user_id: created_by, share: share)
  end

  def self.import(file, current_user_id, file_path)
    current_user = User.find current_user_id

    import_log = CsvImportLog.new(company_id: current_user.company_id, object_name: 'account', source: 'ui')
    import_log.set_file_source(file_path)

    advertiser_type_id = self.advertiser_type_id(current_user.company)
    agency_type_id = self.agency_type_id(current_user.company)

    type_field     = current_user.company.fields.find_by(subject_type: 'Client', name: 'Client Type')
    category_field = current_user.company.fields.find_by(subject_type: 'Client', name: 'Category')
    region_field   = current_user.company.fields.find_by(subject_type: 'Client', name: 'Region')
    segment_field  = current_user.company.fields.find_by(subject_type: 'Client', name: 'Segment')

    @custom_field_names = current_user.company.account_cf_names

    CSV.parse(file, headers: true, header_converters: :symbol) do |row|
      import_log.count_processed
      @has_custom_field_rows ||= (row.headers && @custom_field_names.map(&:to_csv_header)).any?

      if row[1].nil? || row[1].blank?
        import_log.count_failed
        import_log.log_error(['Name is empty'])
        next
      end

      if row[2].nil? || row[2].blank?
        import_log.count_failed
        import_log.log_error(['Type is empty'])
        next
      end

      row[2].downcase!
      if ['agency', 'advertiser'].include? row[2]
        if row[2] == 'advertiser'
          type_id = advertiser_type_id
        else
          type_id = agency_type_id
        end
      else
        import_log.count_failed
        import_log.log_error(['Type is invalid. Use "Agency" or "Advertiser" string'])
        next
      end

      if row[3].present?
        parent = Client.where("company_id = ? and name ilike ?", current_user.company_id, row[3].strip.downcase).first
        unless parent
          import_log.count_failed
          import_log.log_error(["Parent account #{row[3]} could not be found"])
          next
        end
      else
        parent = nil
      end

      if row[4].present? && row[2] == 'advertiser'
        category = category_field.option_from_name(row[4].strip)
        unless category
          import_log.count_failed
          import_log.log_error(["Category #{row[4]} could not be found"])
          next
        end
      else
        category = nil
      end

      if row[5].present? && row[2] == 'advertiser'
        subcategory = category.suboptions.where('name ilike ?', row[5]).first
        unless subcategory
          import_log.count_failed
          import_log.log_error(["Subcategory #{row[5]} could not be found"])
          next
        end
      else
        subcategory = nil
      end

      client_member_list = []
      if row[13].present?
        members = row[13].split(';').map{|el| el.split('/') }

        client_member_list_error = false

        members.each do |member|
          if member[1].nil?
            import_log.count_failed
            import_log.log_error(["Account team member #{member[0]} does not have share"])
            client_member_list_error = true
            break
          elsif user = current_user.company.users.where('email ilike ?', member[0]).first
            client_member_list << user
          else
            import_log.count_failed
            import_log.log_error(["Account team member #{member[0]} could not be found in the users list"])
            client_member_list_error = true
            break
          end
        end

        if client_member_list_error
          next
        end
      end

      if row[14].present?
        region = region_field.option_from_name(row[14].strip)
        unless region
          import_log.count_failed
          import_log.log_error(["Region #{row[14]} could not be found"])
          next
        end
      else
        region = nil
      end

      if row[15].present?
        segment = segment_field.option_from_name(row[15].strip)
        unless segment
          import_log.count_failed
          import_log.log_error(["Segment #{row[15]} could not be found"])
          next
        end
      else
        segment = nil
      end

      if row[16].present? && row[2] == 'agency'
        holding_company = HoldingCompany.where("name ilike ?", row[16].strip.downcase).first
        unless holding_company
          import_log.count_failed
          import_log.log_error(["Holding company #{row[16]} could not be found"])
          next
        end
      else
        holding_company = nil
      end

      address_params = {
        street1: row[6].nil? ? nil : row[6].strip,
        city: row[7].nil? ? nil : row[7].strip,
        state: row[8].nil? ? nil : row[8].strip,
        zip: row[9].nil? ? nil : row[9].strip,
        phone: row[10].nil? ? nil : row[10].strip,
      }

      client_params = {
        name: row[1].strip,
        website: row[11].nil? ? nil : row[11].strip,
        client_type_id: type_id,
        client_category: category,
        client_subcategory: subcategory,
        client_region: region,
        client_segment: segment,
        parent_client: parent,
        holding_company: holding_company
      }

      type_value_params = {
        value_type: 'Option',
        subject_type: 'Client',
        field_id: type_field.id,
        option_id: type_id,
        company_id: current_user.company_id
      }

      category_value_params = {
        value_type: 'Option',
        subject_type: 'Client',
        field_id: category_field.id,
        option_id: (category ? category.id : nil),
        company_id: current_user.company_id
      }

      region_value_params = {
        value_type: 'Option',
        subject_type: 'Client',
        field_id: region_field.id,
        option_id: (region ? region.id : nil),
        company_id: current_user.company_id
      }

      segment_value_params = {
        value_type: 'Option',
        subject_type: 'Client',
        field_id: segment_field.id,
        option_id: (segment ? segment.id : nil),
        company_id: current_user.company_id
      }

      if row[0]
        begin
          client = current_user.company.clients.find(row[0])
        rescue ActiveRecord::RecordNotFound
        end
      end

      unless client.present?
        clients = current_user.company.clients.where('name ilike ?', row[1].strip.downcase)
        if clients.length > 1
          import_log.count_failed
          import_log.log_error(["Account name #{row[1]} matched more than one account record"])
          next
        end
        client = clients.first
      end

      if client.present?
        if parent && parent.id == client.id
          import_log.count_failed
          import_log.log_error(["Accounts can't be parents of themselves"])
          next
        end

        address_params[:id] = client.address.id if client.address
        client_params[:id] = client.id
        type_value_params[:subject_id] = client.id
        category_value_params[:subject_id] = client.id
        region_value_params[:subject_id] = client.id
        segment_value_params[:subject_id] = client.id

        if client_type_field = client.values.find { |value| value.field_id == type_value_params[:field_id] }
          type_value_params[:id] = client_type_field.id
        end

        if client_category_field = client.values.find { |value| value.field_id == category_value_params[:field_id] }
          category_value_params[:id] = client.values.where(field_id: category_value_params[:field_id]).first.id
        end

        if client_region_field = client.values.find { |value| value.field_id == region_value_params[:field_id] }
          region_value_params[:id] = client.values.where(field_id: region_value_params[:field_id]).first.id
        end

        if client_segment_field = client.values.find { |value| value.field_id == segment_value_params[:field_id] }
          segment_value_params[:id] = client.values.where(field_id: segment_value_params[:field_id]).first.id
        end
      else
        client = current_user.company.clients.create(name: row[1].strip)
        client.update_attributes(created_by: current_user.id)
      end

      client_params[:address_attributes] = address_params
      client_params[:values_attributes] = [type_value_params, category_value_params, region_value_params, segment_value_params]

      if client.update_attributes(client_params)
        import_log.count_imported
        client.client_members.delete_all if row[12] == 'Y'
        client_member_list.each_with_index do |user, index|
          client_member = client.client_members.find_or_initialize_by(user: user)
          client_member.update(share: members[index][1].to_i)
        end

        import_custom_field(client, row) if @has_custom_field_rows
      else
        import_log.count_failed
        import_log.log_error(client.errors.full_messages)
        next
      end
    end

    import_log.save
  end

  def self.client_type_field(company)
    company.fields.where(name: 'Client Type').first
  end

  def self.agency_type_id(company)
    client_type_field(company).options.where(name: "Agency").first.id
  end

  def self.advertiser_type_id(company)
    client_type_field(company).options.where(name: "Advertiser").first.id
  end

  def self.custom_types(company)
    opts = {}
    client_type_field(company).options&.each{|c| opts.merge!(c.id => c.name)}
    opts
  end

  def client_type
    company.fields.where(name: 'Client Type').first.options.find_by_id(self.client_type_id)
  end

  def base_field_validations
    self.company.validations_for("#{self.client_type.try(:name)} Base Field")
  end

  def base_fields_presence
    if self.company_id.present? && self.client_type_id.present?
      factors = base_field_validations.joins(:criterion).where('values.value_boolean = ?', true).pluck(:factor)
      self.validates_presence_of(factors) if factors.length > 0
    end
  end

  def global_type_id
    if self.client_type_id
      if self.client_type_id == Client.advertiser_type_id(company)
        Client::ADVERTISER
      elsif self.client_type_id == Client.agency_type_id(company)
        Client::AGENCY
      end
    end
  end

  def last_advertiser_deal(deal)
    (last_two_advertiser_deals.first.eql?(deal) ? last_two_advertiser_deals.last : last_two_advertiser_deals.first).created_at
  end

  def last_two_advertiser_deals
    @_last_two_advertiser_deals ||= advertiser_deals.order('created_at desc').limit(2)
  end

  def last_agency_deal(deal)
    (last_two_agency_deals.first.eql?(deal) ? last_two_agency_deals.last : last_two_agency_deals.first).created_at
  end

  def last_two_agency_deals
    @_last_two_agency_deals ||= agency_deals.order('created_at desc').limit(2)
  end

  def advertiser_win_rate
    return 0 if (advertiser_deals.won.count + advertiser_deals.lost.count).zero?

    (advertiser_deals.won.count.to_f / (advertiser_deals.won.count + advertiser_deals.lost.count).to_f * 100).to_i
  end

  def agency_win_rate
    return 0 if (agency_deals.won.count + agency_deals.lost.count).zero?

    (agency_deals.won.count.to_f / (agency_deals.won.count + agency_deals.lost.count).to_f * 100).to_i
  end

  def advertiser_avg_deal_size
    advertiser_deals.won.map(&:budget).sum / advertiser_deals.won.count if advertiser_deals.won.any?
  end

  def agency_avg_deal_size
    agency_deals.won.map(&:budget).sum / agency_deals.won.count if agency_deals.won.any?
  end

  def upsert_custom_fields(params)
    if self.account_cf.present?
      self.account_cf.update(params)
    else
      cf = self.build_account_cf(params)
      cf.save
    end
  end

  def advertiser_deals_open_pipeline
    advertiser_deals
      .open
      .pluck(:budget)
      .compact
      .reduce(:+)
      &.round(0)
      &.to_i
  end

  private

  def self.import_custom_field(obj, row)
    params = {}

    @custom_field_names.each do |cf|
      params[cf.field_name] = row[cf.to_csv_header]
    end

    if params.compact.any?
      obj.upsert_custom_fields(params)
    end
  end
end
