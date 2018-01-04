class GoogleSpreadsheets::DealSerializer < ActiveModel::Serializer
  EMPTY = ''.freeze
  FIEDLS_ORDER = %w(id opportunity_title brand creative_ideas_needed launch seller csm parent agency region budget).freeze

  attributes :id

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
    EMPTY
  end

  def launch
    "#{object.start_date.strftime('%d/%m/%y')} - #{object.end_date.strftime('%d/%m/%y')}"
  end

  def seller
    seller_user.name
  end

  def agency
    object.agency&.name
  end

  def region
    seller_user.team&.name
  end

  def budget
    object.budget
  end

  alias_method :creative_ideas_needed, :empty
  alias_method :csm, :empty
  alias_method :parent, :empty

  private

  def seller_user
    @_seller ||= object.deal_members.order(:share).first.user
  end
end
