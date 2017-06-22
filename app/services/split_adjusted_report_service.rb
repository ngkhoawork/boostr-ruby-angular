class SplitAdjustedReportService
  def initialize(company)
    @company = company
  end

  def perform
    ActiveModel::ArraySerializer.new(
      DealMember.with_not_zero_share.includes(:user, deal: [:advertiser, :agency]).where(deals: { company_id: company.id }).order(deal_id: :desc),
      each_serializer: SplitAdjustedReportSerializer
    )
  end

  private

  attr_reader :company

end
