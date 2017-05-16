require 'rails_helper'

describe PacingDashboard::PipelineAndRevenueService do
  before do
    create_time_periods_and_time_period_weeks
    create_snapshots
  end

  it 'return proper data for pipeline and revenue service' do
    Timecop.freeze(2017, 2, 2)

    result = new_deal_service.perform
    revenue_current_quarter = result[:revenue][:current_quarter]
    pipeline_current_quarter = result[:weighted_pipeline][:current_quarter]
    forecast_amt_current_quarter = result[:sum_revenue_and_weighted_pipeline][:current_quarter]

    revenue_previous_quarter = result[:revenue][:previous_quarter]
    pipeline_previous_quarter = result[:weighted_pipeline][:previous_quarter]
    forecast_amt_previous_quarter = result[:sum_revenue_and_weighted_pipeline][:previous_quarter]

    revenue_previous_year_quarter = result[:revenue][:previous_year_quarter]
    pipeline_previous_year_quarter = result[:weighted_pipeline][:previous_year_quarter]
    forecast_amt_previous_year_quarter = result[:sum_revenue_and_weighted_pipeline][:previous_year_quarter]

    expect(revenue_current_quarter).to eq [5000, 2000, 20000, 0, 0, 0, 4000, 0, 0, 0, 0, 0]
    expect(revenue_previous_quarter).to eq [15000, 12000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2000, 0]
    expect(revenue_previous_year_quarter).to eq [8000, 0, 0, 0, 0, 10000, 0, 0, 0, 0, 0, 4000, 0]

    expect(pipeline_current_quarter).to eq [10000, 5000, 15000, 0, 0, 0, 1000, 0, 0, 0, 0, 0]
    expect(pipeline_previous_quarter).to eq [20000, 25000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1000, 0]
    expect(pipeline_previous_year_quarter).to eq [2000, 0, 0, 0, 0, 5000, 0, 0, 0, 0, 0, 10000, 0]

    expect(forecast_amt_current_quarter).to eq [15000, 7000, 35000, 0, 0, 0, 5000, 0, 0, 0, 0, 0]
    expect(forecast_amt_previous_quarter).to eq [35000, 37000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3000, 0]
    expect(forecast_amt_previous_year_quarter).to eq [10000, 0, 0, 0, 0, 15000, 0, 0, 0, 0, 0, 14000, 0]
  end

  private

  def new_deal_service
    described_class.new(company)
  end

  def company
    @_company ||= create :company
  end

  def time_period
    @_time_period ||= TimePeriod.first
  end

  def user
    @_user ||= create :user
  end

  def create_snapshots
    create_snapshots_for_current_quarter

    create_snapshots_for_previous_quarter

    create_snapshots_for_previous_year_quarter
  end

  def create_snapshots_for_current_quarter
    Timecop.freeze(2017, 1, 2)
    snapshot = create :snapshot, company: company, user: user, time_period: time_period
    snapshot.update(revenue: 5_000, weighted_pipeline: 10_000)

    Timecop.return
    Timecop.freeze(2017, 1, 10)
    snapshot = create :snapshot, company: company, user: user, time_period: time_period
    snapshot.update(revenue: 2_000, weighted_pipeline: 5_000)

    Timecop.return
    Timecop.freeze(2017, 1, 17)
    snapshot = create :snapshot, company: company, user: user, time_period: time_period
    snapshot.update(revenue: 20_000, weighted_pipeline: 15_000)

    Timecop.return
    Timecop.freeze(2017, 2, 14)
    snapshot = create :snapshot, company: company, user: user, time_period: time_period
    snapshot.update(revenue: 4_000, weighted_pipeline: 1_000)
  end

  def create_snapshots_for_previous_quarter
    Timecop.return
    Timecop.freeze(2016, 10, 2)
    snapshot = create :snapshot, company: company, user: user, time_period: time_period
    snapshot.update(revenue: 15_000, weighted_pipeline: 20_000)

    Timecop.return
    Timecop.freeze(2016, 10, 11)
    snapshot = create :snapshot, company: company, user: user, time_period: time_period
    snapshot.update(revenue: 12_000, weighted_pipeline: 25_000)

    Timecop.return
    Timecop.freeze(2016, 12, 22)
    snapshot = create :snapshot, company: company, user: user, time_period: time_period
    snapshot.update(revenue: 2_000, weighted_pipeline: 1_000)
  end

  def create_snapshots_for_previous_year_quarter
    Timecop.return
    Timecop.freeze(2016, 1, 2)
    snapshot = create :snapshot, company: company, user: user, time_period: time_period
    snapshot.update(revenue: 8_000, weighted_pipeline: 2_000)

    Timecop.return
    Timecop.freeze(2016, 2, 9)
    snapshot = create :snapshot, company: company, user: user, time_period: time_period
    snapshot.update(revenue: 10_000, weighted_pipeline: 5_000)

    Timecop.return
    Timecop.freeze(2016, 3, 22)
    snapshot = create :snapshot, company: company, user: user, time_period: time_period
    snapshot.update(revenue: 4_000, weighted_pipeline: 10_000)
  end
end
