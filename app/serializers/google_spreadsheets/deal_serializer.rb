class GoogleSpreadsheets::DealSerializer < ActiveModel::Serializer
  EMPTY = ''.freeze
  FIEDLS_ORDER = %w(id opportunity_title brand creative_ideas_needed launch seller csm seller_email
                    csm_email parent category sub_category agency region budget demo kpis product
                    bae_deal opportunity_url pitchdate operative_id probability).freeze

  attributes :id

  delegate :company, :deal_custom_field, :advertiser, :deal_members, to: :object
  delegate :deal_custom_field_names, to: :company

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
    find_custom_field_value('Creative Ideas Needed')
  end

  def launch
    "#{object.start_date.strftime('%d-%m-%Y')} - #{object.end_date.strftime('%d-%m-%Y')}"
  end

  def seller
    seller_user&.name
  end

  def csm
    csm_user&.name
  end

  def seller_email
    seller_user&.email
  end

  def csm_email
    csm_user&.email
  end

  def category
    advertiser.category_name
  end

  def sub_category
    advertiser.client_subcategory&.name
  end

  def parent
    advertiser.parent_client_name
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

  def kpis
    "#{find_custom_field_value('KPIs')} #{find_custom_field_value('Strategy Considerations')}"
  end

  def bae_deal
    find_custom_field_value('BAE Deal')
  end

  def product
    object.products.pluck(:name).join(', ')
  end

  def opportunity_url
    "#{ENV['HOST']}#{Rails.application.routes.url_helpers.api_deal_path(object)}"
  end

  def operative_id
    object.integrations&.find_by(external_type: Integration::OPERATIVE)
  end

  def probability
    object.stage.probability
  end

  def pitchdate
    find_custom_field_value('Proposal Due Date')
  end

  alias_method :demo, :empty

  private

  def find_custom_field_value(field_label)
    return EMPTY unless (field_name = deal_custom_field_names.find_by(field_label: field_label)&.field_name)

    deal_custom_field&.public_send(field_name) || EMPTY
  end

  def csm_user
    @_csm_user ||= deal_members.account_manager_users.first&.user
  end

  def seller_user
    @_seller ||= deal_members.order(share: :desc).first&.user
  end
end
