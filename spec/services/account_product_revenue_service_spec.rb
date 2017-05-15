require 'rails_helper'

describe AccountProductRevenueFactService do

  describe '#perform' do

    context 'calculation for content fee products' do

      subject { described_class.new.perform }

      let(:time_dimension) { create(:time_dimension) }
      let(:client) { create(:client) }
      let(:company) { client.company }
      let(:product) { create(:product, revenue_type: 'Content-Fee', company: company) }

      it 'summing the product amount for the matching month for each entry in time_dim' do
        expect{ subject }.to change{ AccountProductRevenueFact.count }.by(1)
      end
    end

  end

end