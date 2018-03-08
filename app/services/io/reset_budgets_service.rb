class Io::ResetBudgetsService
  def initialize(io)
    @io               = io
    @company          = io.company
  end

  def perform
    reset_content_fees
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
end
