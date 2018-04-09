require 'rails_helper'

RSpec.describe PmpItem, 'model' do
  let!(:company) { create :company }

  describe '#destroy' do
    before do
      pmp_item_daily_actuals
      pmp_item_monthly_actuals
    end

    it 'remove records of pmp_item_daily_actuals relation' do
      expect do
        pmp_item.destroy
      end.to change(PmpItemDailyActual, :count).by(-2)
    end

    it 'remove records of pmp_item_monthly_actuals relation' do
      expect do
        pmp_item.destroy
      end.to change(PmpItemMonthlyActual, :count).by(-2)
    end
  end

  private

  def pmp_item
    @_pmp ||= create :pmp_item
  end

  def pmp_item_monthly_actuals
    @_pmp_items ||= create_list :pmp_item_monthly_actual, 2, pmp_item: pmp_item
  end

  def pmp_item_daily_actuals
    @_pmp_item_daily_actuals ||= create_list :pmp_item_daily_actual, 2, pmp_item: pmp_item
  end
end

RSpec.describe PmpItem, 'validations' do
  it { should validate_presence_of(:ssp_deal_id) }
  it { should validate_presence_of(:budget) }
  it { should validate_presence_of(:budget_loc) }
end

RSpec.describe PmpItem, 'associations' do
  it { should belong_to(:pmp) }
  it { should belong_to(:ssp) }
  it { should have_many(:pmp_item_daily_actuals) }
  it { should have_many(:pmp_item_monthly_actuals) }
  it { should belong_to(:product) }
end