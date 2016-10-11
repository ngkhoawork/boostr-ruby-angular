require 'rails_helper'

RSpec.describe DealProductBudget, type: :model do
  context 'scopes' do
    let(:company) { create :company }

    context 'for_time_period' do
      let(:time_period) { create :time_period, start_date: '2015-01-01', end_date: '2015-12-31', company: company }
      let!(:in_deal_product) { create :deal_product_budget, start_date: '2015-02-01', end_date: '2015-2-28'  }
      let!(:out_deal_product) { create :deal_product_budget, start_date: '2016-02-01', end_date: '2016-2-28'  }

      it 'returns deals that are completely in the time period' do
        expect(DealProductBudget.for_time_period(time_period.start_date, time_period.end_date).count).to eq(1)
        expect(DealProductBudget.for_time_period(time_period.start_date, time_period.end_date)).to include(in_deal_product)
      end

      it 'returns deals that are partially in the time period' do
        create :deal_product_budget, start_date: '2015-02-01', end_date: '2016-2-28'
        create :deal_product_budget, start_date: '2014-12-01', end_date: '2015-2-28'

        expect(DealProductBudget.for_time_period(time_period.start_date, time_period.end_date).count).to eq(3)
      end
    end
  end
end
