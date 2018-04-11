class Csv::AccountDecorator
  REQUIRED_OPTIONS = %i(cf_names).freeze

  def initialize(record, opts = {})
    @record = record
    @opts = opts

    REQUIRED_OPTIONS.each { |opt_name| raise "#{opt_name} option must be present" unless @opts[opt_name] }
  end

  delegate :id, :name, :website, to: :@record

  def type
    type_id
  end

  def parent
    @record.parent_client&.name
  end

  def category
    @record.client_category&.name
  end

  def subcategory
    @record.client_subcategory&.name
  end

  def address
    @record.address&.street1
  end

  def city
    @record.address&.city
  end

  def state
    @record.address&.state
  end

  def zip
    @record.address&.zip
  end

  def country
    @record.address&.country
  end

  def phone
    @record.address&.phone
  end

  def team_members
    @record
      .client_members
      .map { |member| "#{member.user.email}/#{member.share}" }
      .join(';')
  end

  def region
    @record.client_region&.name
  end

  def segment
    @record.client_segment&.name
  end

  def holding_company
    @record.holding_company&.name
  end

  private

  def type_id
    @opts[:custom_types][@record.client_type_id]
  end

  def method_missing(method_name, *args)
    cf_name = @opts[:cf_names].detect { |cf_name| cf_name.field_label.parameterize('_') == method_name.to_s }

    if cf_name
      @record.account_cf&.public_send(cf_name.field_name)
    else
      super
    end
  end
end
