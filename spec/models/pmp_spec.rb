require 'rails_helper'

RSpec.describe Pmp, 'model' do
  let!(:company) { create :company, :fast_create_company }

  it 'is valid with name, start_date, end_date and curr_cd' do
    pmp = build :pmp
    expect(pmp).to be_valid
  end

  describe 'sets remaining and delivered budgets when create instance' do
    context 'with budget and budget_loc' do
      let(:pmp) { create :pmp, budget: 100, budget_loc: 110 }

      it 'sets remaining budget' do
        expect(pmp.budget_remaining).to eq(100)
        expect(pmp.budget_remaining_loc).to eq(110)
      end

      it 'sets delivered budget' do
        expect(pmp.budget_delivered).to eq(0)
        expect(pmp.budget_delivered_loc).to eq(0)
      end
    end

    context 'without budget nor budget_loc' do
      it 'does not set remaining budget' do
        expect(pmp.budget_remaining).to be_nil
        expect(pmp.budget_remaining_loc).to be_nil
      end

      it 'does not set delivered budget' do
        expect(pmp.budget_delivered).to be_nil
        expect(pmp.budget_delivered_loc).to be_nil
      end
    end
  end

  it 'updates pmp members date if end_date is changed' do
    pmp_members
    end_date = pmp.end_date + 1.day
    pmp.update(end_date: end_date)
    expect(pmp_members.first.reload.to_date).to eq(end_date)
    expect(pmp_members.last.reload.to_date).to eq(end_date)
  end

  it 'updates end_date as the latest from pmp_item_daily_actuals' do
    end_date = pmp.end_date + 1.day
    pmp_item_daily_actuals.first.update(date: end_date)
    pmp.calculate_end_date!
    expect(pmp.end_date).to eq(end_date)
  end

  it 'returns exchange rate' do
    expect(pmp.exchange_rate).to eq(0.8)
  end

  it 'aggregates budgets from pmp_items' do
    create_list :pmp_item, 2, pmp: pmp, budget_loc: 500
    pmp.update(budget: 0, budget_loc: 0, budget_delivered: 0, budget_delivered_loc: 0, budget_remaining: 0, budget_remaining_loc: 0)
    pmp.calculate_budgets!
    expect(pmp.budget).to eq(1250)
    expect(pmp.budget_loc).to eq(1000)
    expect(pmp.budget_remaining).to eq(1250)
    expect(pmp.budget_remaining_loc).to eq(1000)
    expect(pmp.budget_delivered).to eq(0)
    expect(pmp.budget_delivered_loc).to eq(0)
  end

  describe 'destroys all relations when destroy' do
    before do
      pmp_members
      pmp_item
      pmp_item_daily_actuals
    end

    it 'remove pmp_members' do
      expect do
        pmp.destroy!
      end.to change(PmpMember, :count).by(-2)
    end

    it 'remove pmp_items' do
      expect do
        pmp.destroy
      end.to change(PmpItem, :count).by(-1)
    end

    it 'remove pmp_item_daily_actuals' do
      expect do
        pmp.destroy
      end.to change(PmpItemDailyActual, :count).by(-2)
    end
  end

  private

  def pmp
    exchange_rate
    @_pmp ||= create :pmp, company: company, curr_cd: 'EUR'
  end

  def pmp_members
    @_pmp_members ||= create_list :pmp_member, 2, pmp: pmp, to_date: pmp.end_date
  end

  def pmp_item
    @_pmp_item ||= create :pmp_item, pmp: pmp
  end

  def pmp_item_daily_actuals
    @_pmp_item_daily_actuals ||= create_list :pmp_item_daily_actual, 2, pmp_item: pmp_item
  end

  def currency
    @_currency ||= create :currency, curr_cd: 'EUR', curr_symbol: '€', name: 'Euro'
  end

  def exchange_rate
    @_exchange_rate ||= create :exchange_rate, company: company, rate: 0.8, currency: currency
  end
end

RSpec.describe Pmp, 'scopes' do
  let!(:company) { create :company, :fast_create_company }

  describe 'by name' do
    let!(:pmp1) { create :pmp, name: "pmp 1" }
    let!(:pmp2) { create :pmp, name: "pmp 2" }
    let!(:pmp3) { create :pmp, name: "other" }

    it 'returns pmps by name' do
      expect(Pmp.by_name("pmp").count).to eq(2)
    end
  end

  describe 'by advertiser name' do
    let!(:advertiser1) { create :client, :advertiser, name: 'client 1' }
    let!(:advertiser2) { create :client, :advertiser, name: 'client 2' }
    let!(:advertiser3) { create :client, :advertiser, name: 'other' }
    let!(:pmp1) { create :pmp, advertiser: advertiser1 }
    let!(:pmp2) { create :pmp, advertiser: advertiser2 }
    let!(:pmp3) { create :pmp, advertiser: advertiser3 }

    context 'with advertiser name' do
      it 'returns pmps which have matching advertisers' do
        expect(Pmp.by_advertiser_name('client').count).to eq(2)
      end
    end

    context 'without advertiser name' do 
      it 'returns all pmps' do
        expect(Pmp.by_advertiser_name('').count).to eq(3)
      end
    end
  end

  describe 'by start date' do
    let!(:pmp1) { create :pmp, start_date: Date.new(2017,10,24) }
    let!(:pmp2) { create :pmp, start_date: Date.new(2017,10,12) }
    let!(:pmp3) { create :pmp, start_date: Date.new(2017,11,24) }

    it 'returns pmps with start_date in between matching range' do
      expect(Pmp.by_start_date(Date.new(2017,10,1),Date.new(2017,10,31)).count).to eq(2)
    end
  end
end

RSpec.describe Pmp, 'validations' do
  it { should validate_presence_of(:name) }
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