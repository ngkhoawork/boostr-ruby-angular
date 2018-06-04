require 'rails_helper'

describe PacingDashboard::NewDealService do
  before do
    create_time_periods_and_time_period_weeks
    create_deals
  end

  after(:all) do
    Timecop.return
  end

  it 'return proper count for new deal service' do
    Timecop.freeze(2017, 2, 2) do
      result = new_deal_service.perform
      current_quarter = result[:current_quarter]
      previous_quarter = result[:previous_quarter]
      previous_year_quarter = result[:previous_year_quarter]

      expect(current_quarter).to eq [5, 2, 4, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0]
      expect(previous_quarter).to eq [6, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0]
      expect(previous_year_quarter).to eq [3, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 2, 0]
    end
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

  def create_deals_for_current_quarter
    Timecop.freeze(2017, 1, 2) do
      create_list :deal, 5, company: company
    end

    Timecop.freeze(2017, 1, 10) do
      create_list :deal, 2, company: company
    end

    Timecop.freeze(2017, 1, 17) do
      create_list :deal, 4, company: company
    end

    Timecop.freeze(2017, 2, 14) do
      create_list :deal, 2, company: company
    end
  end

  def create_deals_for_previous_quarter
    Timecop.freeze(2016, 10, 2) do
      create_list :deal, 6, company: company
    end

    Timecop.freeze(2016, 10, 11) do
      create_list :deal, 2, company: company
    end

    Timecop.freeze(2016, 12, 22) do
      create_list :deal, 4, company: company
    end
  end

  def create_deals_for_previous_year_quarter
    Timecop.freeze(2016, 1, 2) do
      create_list :deal, 3, company: company
    end

    Timecop.freeze(2016, 2, 9) do
      create_list :deal, 5, company: company
    end

    Timecop.freeze(2016, 3, 22) do
      create_list :deal, 2, company: company
    end
  end
end
