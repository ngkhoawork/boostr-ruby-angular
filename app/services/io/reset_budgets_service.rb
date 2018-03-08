class Io::ResetBudgetsService
  def initialize(io)
    @io               = io
    @company          = io.company
  end

  def perform
    reset_content_fees
    reset_costs
  end

  private

  attr_reader :io,
              :company

  def reset_content_fees
    ActiveRecord::Base.no_touching do
      io.content_fees.each do |content_fee|
        if io.is_freezed
          ContentFee::ResetFreezedBudgetsService.new(content_fee).perform
        else
          ContentFee::ResetBudgetsService.new(content_fee).perform
        end
      end
    end
  end

  def reset_costs
    # This only happens if start_date or end_date has changed on the Deal and thus it has already be touched
    ActiveRecord::Base.no_touching do
      io.costs.each do |cost|
        if io.is_freezed
          Cost::ResetFreezedAmountsService.new(cost).perform
        else
          Cost::AmountsGenerateService.new(cost).perform
        end
      end
    end
  end
end
