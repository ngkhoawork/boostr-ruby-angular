require 'rails_helper'

describe Report::PipelineSummaryService do
  before do
    create_values
    deal_member1
    deal_member2
    deal_member3
    deal_member_leader
    team_level_3
  end

  it 'pipeline summary service with default params' do
    expect(pipeline_summary_service(company, {}).perform).to_not be_nil
  end

  it 'pipeline summary service with wrong params' do
    closed_date_params = {
      closed_date_start: Date.today.to_formatted_s(:iso8601),
      closed_date_end: Date.tomorrow.to_formatted_s(:iso8601)
    }

    expect(pipeline_summary_service(company, closed_date_params).perform.object.count).to eq(0)
  end

  it 'pipeline summary by source' do
    source = {
      source_id: options.id
    }

    expect(pipeline_summary_service(company, source).perform.object.count).to eq(1)
  end

  it 'pipeline summary by type' do
    type = { type_id: options.id }
    expect(pipeline_summary_service(company, type).perform.object.count).to eq(1)
  end

  it 'pipeline summary find by stage' do
    expect(pipeline_summary_service(company, {stage_ids: [stage.id]}).perform.object.count).to eq(3)
  end

  it 'pipeline summary find by seller' do
    seller_params = { seller_id: deals[0].deal_members.first.user_id }

    expect(pipeline_summary_service(company, seller_params).perform.object.count).to eq(1)
  end

  it 'pipeline summary find by start date' do
    date_params = {
      start_date: start_date - 1.day,
      end_date: end_date - 1.day
    }

    expect(pipeline_summary_service(company, date_params).perform.object.count).to eq(3)
  end

  it 'pipeline summary find by created date' do
    date_params = {
      created_date_start: deals[0].created_at - 1.day,
      created_date_end: deals[0].created_at + 1.day
    }

    expect(pipeline_summary_service(company, date_params).perform.object.count).to eq(3)
  end

  it 'pipeline summary find by parent team' do
    date_params = {
      team_id: team_level_1.id
    }

    expect(pipeline_summary_service(company, date_params).perform.object.count).to eq(3)
  end

  it 'pipeline summary find by level 1 sub team' do
    date_params = {
      team_id: team_level_2.id
    }

    expect(pipeline_summary_service(company, date_params).perform.object.count).to eq(2)
  end

  it 'pipeline summary find by level 2 sub team' do
    date_params = {
      team_id: team_level_3.id
    }

    expect(pipeline_summary_service(company, date_params).perform.object.count).to eq(2)
  end

  private

  def pipeline_summary_service(company, params)
    @pipeline_summary_service ||= described_class.new(company, params)
  end

  def company
    @_company ||= create :company
  end

  def options
    @_option ||= create :option, company: company, field: field
  end

  def field
    @_field ||= create :field, company: company
  end

  def stage
    @_stage ||= create :stage, company: company
  end

  def team_level_1
    @_team_level_1 ||= create :team, company: company
  end

  def team_level_2
    @_team_level_2 ||= create :team, company: company, parent: team_level_1
  end

  def team_level_3
    @_team_level_3 ||= create :team, company: company, parent: team_level_2, leader: leader
  end

  def user1
    @_user1 ||= create :user, company: company, team: team_level_1
  end

  def user2
    @_user2 ||= create :user, company: company, team: team_level_2
  end

  def user3
    @_user3 ||= create :user, company: company, team: team_level_3
  end

  def leader
    @_leader ||= create :user, company: company
  end

  def deal_member1
    @_deal_member1 ||= create :deal_member, deal: deals[0], user: user1
  end

  def deal_member2
    @_deal_member2 ||= create :deal_member, deal: deals[1], user: user2
  end

  def deal_member3
    @_deal_member3 ||= create :deal_member, deal: deals[1], user: user3
  end

  def deal_member_leader
    @_deal_member_leader ||= create :deal_member, deal: deals[2], user: leader
  end

  def create_values
    create :value, company: company, field: field, subject: deals[0], option: options
  end

  def deals
    @_deals ||= create_list :deal, 3, company: company,
                                      start_date: start_date,
                                      end_date: end_date,
                                      stage: stage
  end

  def start_date
    @_start_date ||= Date.parse('2017-04-01')
  end

  def end_date
    @_end_date ||= Date.parse('2017-06-30')
  end
end