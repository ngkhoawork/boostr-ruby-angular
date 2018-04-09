require 'rails_helper'

describe Forecast::PipelineQuarterlyDataSerializer do
  before do
    deal_product
  end

  it 'pipeline quarterly data serialized data' do
    expect(pipeline_quarterly_data.advertiser).to eq(advertiser_data)
    expect(pipeline_quarterly_data.agency).to eq(agency_data)
    expect(pipeline_quarterly_data.stage).to eq(stage_data)
    expect(pipeline_quarterly_data.deal_members).to eq(deal_members_data)
    expect(pipeline_quarterly_data.in_period_amt).to eq(10000)
    expect(pipeline_quarterly_data.split_period_budget).to eq(7000)
    expect(pipeline_quarterly_data.month_amounts.length).to eq(12)
    expect(pipeline_quarterly_data.quarter_amounts.length).to eq(4)
  end

  private

  def pipeline_quarterly_data
    @_pipeline_quarterly_data ||= described_class.new(
      deal,
      filter_start_date: time_period.start_date,
      filter_end_date: time_period.end_date,
      products: [product]
    )
  end

  def deal
    @_deal ||= create :deal, company: company, deal_members: [deal_member], stage: stage, start_date: '2015-04-01', end_date: '2015-06-30'
  end

  def stage
    @_stage ||= create :stage, company: company, probability: 50
  end

  def deal_member
    @_deal_member ||= create :deal_member, share: 70
  end

  def company
    @_company ||= create :company
  end

  def time_period
    @_time_period ||= create :time_period, company: company, start_date: '2015-01-01', end_date: '2015-12-31', period_type: 'year'
  end

  def advertiser
    @_advertiser ||= create :client, company: company, address: address
  end

  def deal_product
    @_deal_product ||= create :deal_product, deal: deal, product: product, budget: 10000, budget_loc: 10000
  end

  def product
    @_product ||= create :product, company: company
  end

  def advertiser_data
    @_advertiser_data ||= Deals::AdvertiserSerializer.new(deal.advertiser).object
  end

  def agency_data
    @_agency_data ||= Deals::AgencySerializer.new(deal.agency).object
  end

  def stage_data
    @_stage_data ||= Deals::StageSerializer.new(stage).object
  end

  def deal_members_data
    @_deal_members_data ||= Deals::DealMemberSerializer.new(deal.deal_members).object
  end
end