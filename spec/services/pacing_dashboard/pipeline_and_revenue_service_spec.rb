require 'rails_helper'
require 'rake'

describe PacingDashboard::PipelineAndRevenueService do
  before do
    create_time_periods_and_time_period_weeks
    create_snapshots
  end

  after(:all) do
    Timecop.return
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

    expect(revenue_current_quarter).to eq [2000, 0, 0, 0, 0, 5000, 0, 0, 5000, 2000, 30000, 0, nil, nil, 6000, nil, nil, nil, nil, nil, nil]
    expect(revenue_previous_quarter).to eq [0, 7000, 0, 0, 1000, 0, 0, 0, 15000, 19000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2000, 0]
    expect(revenue_previous_year_quarter).to eq [0, 14000, 0, 0, 9000, 0, 0, 0, 13000, 0, 0, 0, 0, 10000, 0, 0, 0, 0, 0, 4000, 0]

    expect(pipeline_current_quarter).to eq [4000, 0, 0, 0, 0, 10000, 0, 0, 10000, 5000, 20000, 0, nil, nil, 1500, nil, nil, nil, nil, nil, nil]
    expect(pipeline_previous_quarter).to eq [0, 12000, 0, 0, 2000, 0, 0, 0, 20000, 30000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1000, 0]
    expect(pipeline_previous_year_quarter).to eq [0, 12000, 0, 0, 6000, 0, 0, 0, 3000, 0, 0, 0, 0, 5000, 0, 0, 0, 0, 0, 10000, 0]

    expect(forecast_amt_current_quarter).to eq [6000, 0, 0, 0, 0, 15000, 0, 0, 15000, 7000, 50000, 0, nil, nil, 7500, nil, nil, nil, nil, nil, nil]
    expect(forecast_amt_previous_quarter).to eq [0, 19000, 0, 0, 3000, 0, 0, 0, 35000, 49000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3000, 0]
    expect(forecast_amt_previous_year_quarter).to eq [0, 26000, 0, 0, 15000, 0, 0, 0, 16000, 0, 0, 0, 0, 15000, 0, 0, 0, 0, 0, 14000, 0]
  end

  private

  def new_deal_service
    described_class.new(company, {})
  end

  def company
    @_company ||= create :company
  end

  def current_quarter_time_period
    @_current_quarter_time_period ||= TimePeriod.find_by(name: 'Q1-2017')
	end

	def previous_quarter_time_period
		@_previous_quarter_time_period ||= TimePeriod.find_by(name: 'Q4-2016')
	end

	def previous_year_quarter_time_period
		@_previous_year_quarter_time_period ||= TimePeriod.find_by(name: 'Q1-2016')
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
    Timecop.freeze(2016, 11, 7)
    snapshot = create :snapshot, company: company, user: user, time_period: current_quarter_time_period
    snapshot.update(revenue: 2_000, weighted_pipeline: 4_000)

    Timecop.return
    Timecop.freeze(2016, 12, 16)
    snapshot = create :snapshot, company: company, user: user, time_period: current_quarter_time_period
    snapshot.update(revenue: 5_000, weighted_pipeline: 10_000)

    Timecop.return
    Timecop.freeze(2017, 1, 2)
    snapshot = create :snapshot, company: company, user: user, time_period: current_quarter_time_period
    snapshot.update(revenue: 15_000, weighted_pipeline: 20_000)

    Timecop.return
    Timecop.freeze(2017, 1, 8)
    snapshot = create :snapshot, company: company, user: user, time_period: current_quarter_time_period
    snapshot.update(revenue: 5_000, weighted_pipeline: 10_000)

    Timecop.return
    Timecop.freeze(2017, 1, 10)
    snapshot = create :snapshot, company: company, user: user, time_period: current_quarter_time_period
    snapshot.update(revenue: 2_000, weighted_pipeline: 5_000)

    Timecop.return
    Timecop.freeze(2017, 1, 17)
    snapshot = create :snapshot, company: company, user: user, time_period: current_quarter_time_period
    snapshot.update(revenue: 20_000, weighted_pipeline: 15_000)

		snapshot = create :snapshot, company: company, user: user, time_period: current_quarter_time_period
		snapshot.update(revenue: 10_000, weighted_pipeline: 5_000)

    Timecop.return
    Timecop.freeze(2017, 2, 14)
    snapshot = create :snapshot, company: company, user: user, time_period: current_quarter_time_period
		snapshot.update(revenue: 4_000, weighted_pipeline: 1_000)

		snapshot = create :snapshot, company: company, user: user, time_period: current_quarter_time_period
		snapshot.update(revenue: 2_000, weighted_pipeline: 500)
  end

  def create_snapshots_for_previous_quarter
    Timecop.return
    Timecop.freeze(2016, 8, 17)
    snapshot = create :snapshot, company: company, user: user, time_period: previous_quarter_time_period
    snapshot.update(revenue: 7_000, weighted_pipeline: 12_000)

    Timecop.return
    Timecop.freeze(2016, 9, 5)
    snapshot = create :snapshot, company: company, user: user, time_period: previous_quarter_time_period
    snapshot.update(revenue: 1_000, weighted_pipeline: 2_000)

    Timecop.return
    Timecop.freeze(2016, 10, 2)
    snapshot = create :snapshot, company: company, user: user, time_period: previous_quarter_time_period
    snapshot.update(revenue: 15_000, weighted_pipeline: 20_000)

    Timecop.return
    Timecop.freeze(2016, 10, 11)
    snapshot = create :snapshot, company: company, user: user, time_period: previous_quarter_time_period
    snapshot.update(revenue: 12_000, weighted_pipeline: 25_000)

		snapshot = create :snapshot, company: company, user: user, time_period: previous_quarter_time_period
		snapshot.update(revenue: 7_000, weighted_pipeline: 5_000)

    Timecop.return
    Timecop.freeze(2016, 12, 22)
    snapshot = create :snapshot, company: company, user: user, time_period: previous_quarter_time_period
    snapshot.update(revenue: 2_000, weighted_pipeline: 1_000)
  end

  def create_snapshots_for_previous_year_quarter
    Timecop.return
    Timecop.freeze(2015, 11, 16)
    snapshot = create :snapshot, company: company, user: user, time_period: previous_year_quarter_time_period
    snapshot.update(revenue: 14_000, weighted_pipeline: 12_000)

    Timecop.return
    Timecop.freeze(2015, 12, 7)
    snapshot = create :snapshot, company: company, user: user, time_period: previous_year_quarter_time_period
    snapshot.update(revenue: 9_000, weighted_pipeline: 6_000)

    Timecop.return
    Timecop.freeze(2016, 1, 2)
    snapshot = create :snapshot, company: company, user: user, time_period: previous_year_quarter_time_period
    snapshot.update(revenue: 8_000, weighted_pipeline: 2_000)

		snapshot = create :snapshot, company: company, user: user, time_period: previous_year_quarter_time_period
		snapshot.update(revenue: 5_000, weighted_pipeline: 1_000)

    Timecop.return
    Timecop.freeze(2016, 2, 9)
    snapshot = create :snapshot, company: company, user: user, time_period: previous_year_quarter_time_period
    snapshot.update(revenue: 10_000, weighted_pipeline: 5_000)

    Timecop.return
    Timecop.freeze(2016, 3, 22)
    snapshot = create :snapshot, company: company, user: user, time_period: previous_year_quarter_time_period
    snapshot.update(revenue: 4_000, weighted_pipeline: 10_000)
  end
end
