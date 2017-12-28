class FilterData::BaseSerializer < ActiveModel::Serializer
  attribute :max_budget

  has_many :members, serializer: Deals::FilterData::MemberSerializer
  has_many :advertisers, serializer: Deals::AdvertiserSerializer
  has_many :agencies, serializer: Deals::AgencySerializer
  has_many :currencies, serializer: Deals::FilterData::CurrencySerializer
  has_many :teams, serializer: Deals::FilterData::TeamSerializer

  private

  def max_budget
    object.deals.maximum(:budget).to_i
  end

  def members
    object.users
  end

  def teams
    object.teams
  end

  def advertisers
    object.clients.by_type_id(advertiser_id)
  end

  def agencies
    object.clients.by_type_id(agency_id)
  end

  def currencies
    object.exchange_rates.includes(:currency).map(&:currency).push(Currency.find_by(name: 'United States dollar'))
  end

  def advertiser_id
    Client.advertiser_type_id(object)
  end

  def agency_id
    Client.agency_type_id(object)
  end
end
