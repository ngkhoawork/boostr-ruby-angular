class Deal::ResetBudgetsService
  def initialize(deal)
    @deal             = deal
    @company          = deal.company
  end

  def perform
    reset_deal_products
  end

  private

  attr_reader :deal,
              :company

  def reset_deal_products
    ActiveRecord::Base.no_touching do
      deal.deal_products.each do |deal_product|
        if deal.freezed?
          DealProduct::ResetFreezedBudgetsService.new(deal_product).perform
        else
          DealProduct::ResetBudgetsService.new(deal_product).perform
        end
      end
    end
  end
end
