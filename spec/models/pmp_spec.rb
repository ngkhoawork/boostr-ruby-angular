require 'rails_helper'

RSpec.describe Pmp, 'model' do
  describe '#destroy' do
    before do
      pmp_members
      pmp_items
      pmp_item_daily_actuals
    end

    it 'remove records of pmp_members relation' do
      expect do
        pmp.destroy
      end.to change(PmpMember, :count).by(-2)
    end

    it 'remove records of pmp_items relation' do
      expect do
        pmp.destroy
      end.to change(PmpItem, :count).by(-2)
    end

    it 'remove records of pmp_item_daily_actuals relation' do
      expect do
        pmp.destroy
      end.to change(PmpItemDailyActual, :count).by(-2)
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def pmp
    @_pmp ||= create :pmp, company: company
  end

  def pmp_members
    @_pmp_members ||= create_list :pmp_member, 2, pmp: pmp
  end

  def pmp_items
    @_pmp_items ||= create_list :pmp_item, 2, pmp: pmp
  end

  def pmp_item_daily_actuals
    @_pmp_item_daily_actuals ||= create_list :pmp_item_daily_actual, 2, pmp_item: pmp_items.first
  end
end

RSpec.describe Pmp, 'scopes' do
  describe 'by_name' do
    let!(:pmp1) { create :pmp, name: "pmp 1" }
    let!(:pmp2) { create :pmp, name: "pmp 2" }
    let!(:pmp3) { create :pmp, name: "other" }

    it 'returns pmps by name' do
      expect(Pmp.by_name("pmp").count).to eq(2)
    end
  end
end

RSpec.describe Pmp, 'validations' do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:budget) }
  it { should validate_presence_of(:budget_loc) }
  it { should validate_presence_of(:start_date) }
  it { should validate_presence_of(:end_date) }
  it { should validate_presence_of(:curr_cd) }
end

RSpec.describe Pmp, 'associations' do
  it { should belong_to(:company) }
  it { should belong_to(:deal) }
  it { should belong_to(:advertiser) }
  it { should belong_to(:agency) }
  it { should have_many(:pmp_members) }
  it { should have_many(:pmp_items) }
  it { should have_many(:pmp_item_daily_actuals) }
  it { should have_one(:currency) }
end