require 'rails_helper'

RSpec.describe Quota, type: :model do
  describe 'scopes' do
    before do
      create_list :quota, 2
    end

    context 'for_time_period' do
      before do
        create :quota, time_period: time_period
      end

      it 'returns the quotas scoped to the given time period id' do
        expect(Quota.count).to eq(3)
        expect(Quota.for_time_period(time_period.start_date, time_period.end_date).length).to eq(1)
      end
    end

    context 'by_type' do
      before do
        create :quota, value_type: QUOTA_TYPES[:net]
      end

      it 'returns the quotas scoped to the given type(net, gross)' do
        expect(Quota.count).to eq(3)
        expect(Quota.by_type(QUOTA_TYPES[:net]).length).to eq(1)
      end
    end

    context 'by_product_type' do
      before do
        create :quota, product: product_family
      end

      it 'returns the quotas scoped to the given product family' do
        expect(Quota.count).to eq(3)
        expect(Quota.by_product_type('ProductFamily').length).to eq(1)
      end
    end

    context 'by_product_id' do
      before do
        create :quota, product: product
      end

      it 'returns the quotas scoped to the given product id' do
        expect(Quota.count).to eq(3)
        expect(Quota.by_product_id(product.id).length).to eq(1)
      end
    end
  end

  private

  def time_period
    @_time_period ||= create :time_period, start_date: '2018-01-01', end_date: '2018-02-28'
  end

  def product_family
    @_product_family ||= create :product_family
  end

  def product
    @_product ||= create :product
  end
end

RSpec.describe Quota, 'validations' do
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:time_period_id) }
  it { should validate_presence_of(:company_id) }
  it { should validate_presence_of(:value_type) }
end

RSpec.describe Quota, 'associations' do
  it { should belong_to(:user) }
  it { should belong_to(:time_period) }
  it { should belong_to(:company) }
  it { should belong_to(:product) }
end