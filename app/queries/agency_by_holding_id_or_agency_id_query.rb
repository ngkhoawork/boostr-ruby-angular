class AgencyByHoldingIdOrAgencyIdQuery
  def initialize(options = {}, relation = default_relation)
    @options = options
    @relation = relation.extending(Scopes)
  end

  def perform
    return relation if options.blank?
    relation
        .joins('LEFT JOIN holding_companies on holding_companies.id = account_dimensions.holding_company_id')
        .by_company_id(options[:company_id])
        .by_holding_company(options[:holding_company_id])
        .by_account_id(options[:account_id])
        .by_agency_type
  end

  private

  attr_reader :relation, :options

  def default_relation
    AccountDimension.all
  end

  module Scopes
    def by_holding_company(holding_company_id)
      return self unless holding_company_id
      where('holding_company_id = ?', holding_company_id)
    end

    def by_company_id(company_id)
      return self unless company_id
      where('company_id = ?', company_id)
    end

    def by_account_id(account_id)
      return self unless account_id

      where('account_dimensions.id IN (?)', account_id)
    end

    def by_agency_type
      where('account_dimensions.account_type = ?', Client::AGENCY)
    end
  end
end