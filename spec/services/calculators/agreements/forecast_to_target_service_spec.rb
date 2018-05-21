require 'rails_helper'

describe 'Calculators::Agreements::ForecastToTargetService' do
  describe '.perform' do
    it 'calculates forecast to target amount' do
      result = Calculators::Agreements::ForecastToTargetService.new(revenue_amount: revenue_amount,
                                                                    weighted_pipeline: weighted_pipeline,
                                                                    target_amount: target_amount).perform
      expected_result = (revenue_amount + weighted_pipeline / target_amount) * 100

      expect(result).to eq(expected_result)
    end
  end

  private

  def revenue_amount
    1000
  end

  def weighted_pipeline
    900
  end

  def target_amount
    1000
  end
end