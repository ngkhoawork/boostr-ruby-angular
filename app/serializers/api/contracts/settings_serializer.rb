class Api::Contracts::SettingsSerializer
  def initialize(company, *_args)
    @company = company
  end

  def as_json(*_args)
    {
      type_options: options_for(type_field),
      status_options: options_for(status_field),
      member_role_options: options_for(member_role_field),
      special_term_name_options: options_for(special_term_name_field),
      special_term_type_options: options_for(special_term_type_field),
      linked_deals: linked_deals,
      linked_advertisers: linked_advertisers,
      linked_agencies: linked_agencies,
      linked_holding_companies: linked_holding_companies,
      linked_users: linked_users
    }
  end

  private

  def type_field
    field_by_name('Type')
  end

  def status_field
    field_by_name('Status')
  end

  def member_role_field
    field_by_name('Member Role')
  end

  def special_term_name_field
    field_by_name('Special Term Name')
  end

  def special_term_type_field
    field_by_name('Special Term Type')
  end

  def linked_deals
    @company.deals.joins(:contracts).distinct.map { |deal| deal.serializable_hash(only: [:id, :name]) }
  end

  def linked_advertisers
    @company.clients.joins(:advertiser_contracts).distinct.map do |advertiser|
      advertiser.serializable_hash(only: [:id, :name])
    end
  end

  def linked_agencies
    @company.clients.joins(:agency_contracts).distinct.map { |agency| agency.serializable_hash(only: [:id, :name]) }
  end

  def linked_holding_companies
    HoldingCompany.joins(:contracts).where(contracts: { company_id: @company.id }).distinct.map do |holding_company|
      holding_company.serializable_hash(only: [:id, :name])
    end
  end

  def linked_users
    @company.users.joins(:contract_members).distinct.map { |user| user.serializable_hash(only: :id, methods: :name) }
  end

  def field_by_name(name)
    @company.fields.find_by(subject_type: 'Contract', name: name)
  end

  def options_for(field)
    return [] unless field

    field.options.map { |option| option.serializable_hash(only: [:id, :field_id, :name, :position, :option_id]) }
  end
end
