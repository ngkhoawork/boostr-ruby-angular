class GoogleSpreadsheets::DealSerializer < ActiveModel::Serializer
  EMPTY = ''.freeze
  FIEDLS_ORDER = %w(id opportunity_title brand creative_ideas_needed launch seller csm parent agency region budget).freeze

  attributes :id

  delegate :company, :deal_custom_field, to: :object

  def to_spreadsheet
    { values: [FIEDLS_ORDER.map { |field_name| public_send(field_name) }] }
  end

  def empty
    EMPTY
  end

  def opportunity_title
    "#{object.id}-#{object.name}"
  end

  def brand
    object.advertiser_name
  end

  def creative_ideas_needed
    field_name = company.deal_custom_field_names
                        .find_by(field_label: 'Creative Ideas Needed')&.field_name

    field_name ? deal_custom_field&.public_send(field_name) : EMPTY
  end

  def launch
    "#{object.start_date.strftime('%d/%m/%y')} - #{object.end_date.strftime('%d/%m/%y')}"
  end

  def seller
    seller_user&.name
  end

  def agency
    object.agency&.name
  end

  def region
    name = seller_user&.team&.name

    name ? name : EMPTY
  end

  def budget
    object.budget.to_f
  end

  alias_method :csm, :empty
  alias_method :parent, :empty

  private

  def seller_user
    @_seller ||= object.deal_members.order(share: :desc).first&.user
  end
end
