class AgencyByHoldingIdOrAgencyIdQuery
  def initialize(options = {}, relation = AccountDimension.agency)
    @options = options
    @relation = relation
  end

  def call
    return relation if options.blank?
    relation.joins('LEFT JOIN holding_companies on holding_companies.id = account_dimensions.holding_company_id')
            .where('company_id = ? AND (account_dimensions.id = ? OR holding_company_id = ?)',
                   options[:user_id],
                   options[:account_id],
                   options[:holding_company_id])
  end

  private

  attr_reader :relation, :options
end