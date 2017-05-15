require 'rails_helper'

describe PacingDashboard::NewDealService do
  before do
    create_time_periods_and_time_period_weeks
    create_deals
  end

  it 'return proper count for new deal service' do
    Timecop.freeze(2017, 2, 2)

    result = new_deal_service.perform
    current_quarter = result[:current_quarter]
    previous_quarter = result[:previous_quarter]
    previous_year_quarter = result[:previous_year_quarter]

    expect(current_quarter[Date.new(2017, 1, 1)]).to eq(5)
    expect(current_quarter[Date.new(2017, 1, 9)]).to eq(2)
    expect(current_quarter[Date.new(2017, 1, 16)]).to eq(4)
    expect(current_quarter[Date.new(2017, 2, 13)]).to eq(2)

    expect(previous_quarter[Date.new(2016, 10, 1)]).to eq(6)
    expect(previous_quarter[Date.new(2016, 10, 10)]).to eq(2)
    expect(previous_quarter[Date.new(2016, 12, 19)]).to eq(4)

    expect(previous_year_quarter[Date.new(2016, 1, 1)]).to eq(3)
    expect(previous_year_quarter[Date.new(2016, 2, 8)]).to eq(5)
    expect(previous_year_quarter[Date.new(2016, 3, 21)]).to eq(2)
  end

  private

  def new_deal_service
    described_class.new(company)
  end

  def company
    @_company ||= create :company
  end

  def create_deals
    create_deals_for_current_quarter

    create_deals_for_previous_quarter

    create_deals_for_previous_year_quarter
  end

  def create_deals_for_current_quarter
    Timecop.freeze(2017, 1, 2)
    create_list :deal, 5, company: company

    Timecop.return
    Timecop.freeze(2017, 1, 10)
    create_list :deal, 2, company: company

    Timecop.return
    Timecop.freeze(2017, 1, 17)
    create_list :deal, 4, company: company

    Timecop.return
    Timecop.freeze(2017, 2, 14)
    create_list :deal, 2, company: company
  end

  def create_deals_for_previous_quarter
    Timecop.return
    Timecop.freeze(2016, 10, 2)
    create_list :deal, 6, company: company

    Timecop.return
    Timecop.freeze(2016, 10, 11)
    create_list :deal, 2, company: company

    Timecop.return
    Timecop.freeze(2016, 12, 22)
    create_list :deal, 4, company: company
  end

  def create_deals_for_previous_year_quarter
    Timecop.return
    Timecop.freeze(2016, 1, 2)
    create_list :deal, 3, company: company

    Timecop.return
    Timecop.freeze(2016, 2, 9)
    create_list :deal, 5, company: company

    Timecop.return
    Timecop.freeze(2016, 3, 22)
    create_list :deal, 2, company: company
  end
end
