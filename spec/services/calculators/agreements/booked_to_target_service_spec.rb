require 'rails_helper'

describe 'Calculators::Agreements::BookedToTargetService' do
  describe '.perform' do
    it 'calculates booked to target amount' do
      result = Calculators::Agreements::BookedToTargetService.new(target_amount: target_amount,
                                                         revenue_amount: revenue_amount).perform
      expected_result = revenue_amount / target_amount * 100

      expect(result).to eq(expected_result)
    end
  end

  private

  def target_amount
    1000
  end

  def revenue_amount
    900
  end
end