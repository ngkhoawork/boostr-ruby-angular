require 'rails_helper'

RSpec.describe DealProduct, type: :model do
  context 'scopes' do
    let(:company) { create :company }

    context 'for_time_period' do
      let(:time_period) { create :time_period, start_date: '2015-01-01', end_date: '2015-12-31', company: company }
      let!(:in_deal_product) { create :deal_product, start_date: '2015-02-01', end_date: '2015-2-28'  }
      let!(:out_deal_product) { create :deal_product, start_date: '2016-02-01', end_date: '2016-2-28'  }

      it 'returns all deals when no time period is specified' do
        expect(DealProduct.for_time_period(nil).count).to eq(2)
      end

      it 'returns deals that are completely in the time period' do
        expect(DealProduct.for_time_period(time_period).count).to eq(1)
        expect(DealProduct.for_time_period(time_period)).to include(in_deal_product)
      end

      it 'returns deals that are partially in the time period' do
        create :deal_product, start_date: '2015-02-01', end_date: '2016-2-28'
        create :deal_product, start_date: '2014-12-01', end_date: '2015-2-28'

        expect(DealProduct.for_time_period(time_period).count).to eq(3)
      end
    end
  end
end
