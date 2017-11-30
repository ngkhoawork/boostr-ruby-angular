require 'rails_helper'

describe Forecast::PipelineDataSerializer do
  before do
    deal_product
  end

  it 'pipeline data serialized data' do
    expect(pipeline_data.client_name).to eq(client_name)
    expect(pipeline_data.agency_name).to eq(agency_name)
    expect(pipeline_data.probability).to eq(stage.probability)
    expect(pipeline_data.wday_in_stage).to eq(deal.wday_in_stage)
    expect(pipeline_data.wday_since_opened).to eq(deal.wday_since_opened)
    expect(pipeline_data.in_period_amt).to eq(10000)
    expect(pipeline_data.wday_since_opened_color).to eq(nil)
    expect(pipeline_data.wday_in_stage_color).to eq(nil)
  end

  private

  def pipeline_data
    @_pipeline_data ||= described_class.new(deal, filter_start_date: time_period.start_date, filter_end_date: time_period.end_date, products: [product])
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

  def contact
    @_contact ||= create :contact,
                         clients: [advertiser],
                         company: company,
                         address: address
  end

  def deal_product
    @_deal_product ||= create :deal_product, deal: deal, product: product, budget: 10000, budget_loc: 10000
  end

  def product
    @_product ||= create :product, company: company
  end

  def client_name
    @_client_name ||= deal.advertiser.name rescue nil
  end

  def agency_name
    @_agency_name ||= deal.agency.name rescue nil
  end
end