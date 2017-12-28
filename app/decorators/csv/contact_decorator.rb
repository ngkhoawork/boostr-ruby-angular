class Csv::ContactDecorator
  def initialize(contact)
    @contact = contact

    define_contact_cf_accessors
  end

  delegate :id, :name, :position, :job_level, to: :contact

  def works_at
    contact&.primary_client&.name
  end

  def email
    address&.email
  end

  def street1
    address&.street1
  end

  def street2
    address&.street2
  end

  def city
    address&.city
  end

  def state
    address&.state
  end

  def zip
    address&.zip
  end

  def country
    address&.country
  end

  def phone
    address&.phone
  end

  def mobile
    address&.mobile
  end

  def related_accounts
    return '' if contact.non_primary_clients.empty?

    contact.non_primary_clients.pluck(:name).join(';')
  end

  def job_level
    contact.job_level
  end

  def contact_cf
    @contact_cf ||= Hash(contact.contact_cf.as_json)
  end

  def address
    @address ||= contact&.address
  end

  private

  attr_reader :contact

  def define_contact_cf_accessors
    contact_cf_names = contact.company.contact_cf_names.where.not(disabled: true).order(position: :asc)

    contact_cf_names.each do |contact_cf_name|
      define_method(contact_cf_name.field_label.parameterize('_')) do
        contact_cf_value(contact_cf_name)
      end
    end
  end

  def contact_cf_value(contact_cf_name)
    field_name = contact_cf_name.field_type + contact_cf_name.field_index.to_s

    case contact_cf_name.field_type
    when "currency"
      "$" + contact_cf[field_name].to_s
    when "percentage"
      contact_cf[field_name].to_s + "%"
    when "number", "integer"
      contact_cf[field_name].to_s
    when "datetime"
      contact_cf[field_name]&.strftime("%Y-%m-%d %H:%M:%S").to_s
    else
      contact_cf[field_name].to_s
    end
  end
end
