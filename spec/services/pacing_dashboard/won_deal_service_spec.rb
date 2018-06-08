require 'rails_helper'

describe PacingDashboard::WonDealService do
  before do
    create_time_periods_and_time_period_weeks
    create_deals
  end

  after(:all) do
    Timecop.return
  end

  it 'return proper data for won deal service' do
    Timecop.freeze(2017, 2, 2)

    result = new_deal_service.perform
    current_quarter = result[:current_quarter]
    previous_quarter = result[:previous_quarter]
    previous_year_quarter = result[:previous_year_quarter]

    expect(current_quarter).to eq [50000, 10000, 80000, 0, 0, 0, 30000, 0, 0, 0, 0, 0, 0]
    expect(previous_quarter).to eq [12000, 20000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20000, 0]
    expect(previous_year_quarter).to eq [15000, 0, 0, 0, 0, 5000, 0, 0, 0, 0, 0, 40000, 0]
  end

  private

  def new_deal_service
    described_class.new(company, {})
  end

  def company
    @_company ||= create :company
  end

  def create_deals
    create_deals_for_current_quarter

    create_deals_for_previous_quarter

    create_deals_for_previous_year_quarter
  end

  def stage
    @_stage ||= create :closed_won_stage, company: company, position: 1
  end

  def create_deals_for_current_quarter
    Timecop.freeze(2017, 1, 2)
    create_list :deal, 5, company: company, stage: stage, budget: 10_000

    Timecop.return
    Timecop.freeze(2017, 1, 10)
    create_list :deal, 2, company: company, stage: stage, budget: 5_000

    Timecop.return
    Timecop.freeze(2017, 1, 17)
    create_list :deal, 4, company: company, stage: stage, budget: 20_000

    Timecop.return
    Timecop.freeze(2017, 2, 14)
    create_list :deal, 2, company: company, stage: stage, budget: 15_000
  end

  def create_deals_for_previous_quarter
    Timecop.return
    Timecop.freeze(2016, 10, 2)
    create_list :deal, 6, company: company, stage: stage, budget: 2_000

    Timecop.return
    Timecop.freeze(2016, 10, 11)
    create_list :deal, 2, company: company, stage: stage, budget: 10_000

    Timecop.return
    Timecop.freeze(2016, 12, 22)
    create_list :deal, 4, company: company, stage: stage, budget: 5_000
  end

  def create_deals_for_previous_year_quarter
    Timecop.return
    Timecop.freeze(2016, 1, 2)
    create_list :deal, 3, company: company, stage: stage, budget: 5_000

    Timecop.return
    Timecop.freeze(2016, 2, 9)
    create_list :deal, 5, company: company, stage: stage, budget: 1_000

    Timecop.return
    Timecop.freeze(2016, 3, 22)
    create_list :deal, 2, company: company, stage: stage, budget: 20_000
  end

  def create_time_periods
    create_current_time_period

    create_previous_time_period

    create_previous_year_time_period
  end
end
