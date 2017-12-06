require 'rails_helper'

describe Forecast::PipelineDataService do
  before do
    deal_member
    deal_member2
    create :deal_product_budget, deal_product: deal_product
    create :deal_product_budget, deal_product: deal_product2
  end

  it 'return correct pipeline data service for a member' do
    params = {
      time_period_id: time_period.id,
      member_id: user.id
    };
    expect(
      pipeline_data_service(company, params).perform.object.to_a
    ).to eq([deal])
  end

  it 'return correct pipeline data service for a team' do
    params = {
      time_period_id: time_period.id,
      team_id: team.id
    };
    expect(
      pipeline_data_service(company, params).perform.object.count
    ).to eq(2)
  end

  it 'return correct pipeline data service for a product' do
    params = {
      time_period_id: time_period.id,
      team_id: team.id,
      product_id: product2.id
    };
    expect(
      pipeline_data_service(company, params).perform.object.to_a
    ).to eq([deal2])
  end
  
  it 'return correct pipeline data service for a product family' do
    params = {
      time_period_id: time_period.id,
      team_id: team.id,
      product_family_id: product_family.id
    };
    expect(
      pipeline_data_service(company, params).perform.object.count
    ).to eq(2)
  end

  private

  def pipeline_data_service(company, params)
    @pipeline_data_service ||= described_class.new(company, params)
  end

  def discuss_stage
    @_discuss_stage ||= create :discuss_stage
  end

  def company
    @_company ||= create :company
  end

  def time_period
    @_time_period ||= create :time_period, company: company, start_date: '2015-01-01', end_date: '2015-12-31', period_type: 'year'
  end

  def team
    @_team ||= create :team, company: company
  end

  def user
    @_user ||= create :user, company: company, win_rate: 0.5, average_deal_size: 300, team: team
  end
  
  def user2
    @_user2 ||= create :user, company: company, win_rate: 0.5, average_deal_size: 300, team: team
  end

  def deal
    @_deal ||= create :deal, company: company
  end

  def deal2
    @_deal2 ||= create :deal, company: company
  end
  
  def deal_member
    @_deal_member||= create :deal_member, deal: deal, user: user
  end

  def deal_member2
    @_deal_member2 ||= create :deal_member, deal: deal2, user: user2
  end

  def deal_product
    @_deal_product ||= create :deal_product, deal: deal, product: product
  end

  def deal_product2
    @_deal_product2 ||= create :deal_product, deal: deal2, product: product2
  end

  def product_family
    @_product_family ||= create :product_family, company: company
  end

  def product
    @_product ||= create :product, company: company, product_family: product_family
  end

  def product2
    @_product2 ||= create :product, company: company, product_family: product_family
  end

  def close_stage
    @_close_stage ||= create :closed_won_stage
  end
end