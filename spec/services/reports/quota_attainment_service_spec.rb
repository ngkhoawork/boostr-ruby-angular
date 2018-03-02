require 'rails_helper'

describe Report::QuotaAttainmentService do
  it 'is invalid without time_period_id' do
    quota_attainment_service.valid?
    expect(quota_attainment_service.errors.full_messages).to include("Time period can't be blank")
  end

  it 'is invalid with non-existing time_period_id' do
    quota_attainment_service({time_period_id: time_period.id + 1}).valid?
    expect(quota_attainment_service.errors.full_messages).to include("Time period - #{time_period.id + 1} can't be found")
  end

  describe 'generates quota attainment report' do
    before do
      forecast_revenue_fact
      forecast_pipeline_fact
      quota
      quota_attainment_service({time_period_id: time_period.id})
    end

    subject { quota_attainment_service.perform }

    it 'calculates revenue' do
      expect(subject.first[:revenue]).to eq(250)
    end

    it 'calculates weighted_pipeline' do
      expect(subject.first[:weighted_pipeline]).to eq(45)
    end

    it 'calculates quota' do
      expect(subject.first[:quota]).to eq(1100)
    end

    it 'calculates total amount' do
      expect(subject.first[:amount]).to eq(295)
    end

    it 'calculates % to quota' do
      expect(subject.first[:percent_to_quota].round).to eq((295.to_f/11).round)
    end

    it 'calculates % booked' do
      expect(subject.first[:percent_booked].round).to eq((250.to_f/11).round)
    end

    it 'calculates gap to quota' do
      expect(subject.first[:gap_to_quota]).to eq(1100-295)
    end

    it 'sum team members revenue and weighted_pipeline for leader' do
      other_user = create :user, company: company, team: team
      create_list :forecast_pipeline_fact, 2, forecast_time_dimension: forecast_time_dimension, 
                  user_dimension_id: other_user.id, amount: 300, stage_dimension_id: stage.id
      create_list :forecast_revenue_fact, 2, forecast_time_dimension: forecast_time_dimension, 
                  user_dimension_id: other_user.id, amount: 150
      team.update(leader_id: user.id)
      leader_data = subject.detect{|u| u[:is_leader]}
      expect(leader_data[:revenue]).to eq(550)
      expect(leader_data[:weighted_pipeline]).to eq(105)
    end

    context 'with child team' do
      before do
        child_team = create :child_team, parent: team, company: company
        other_user = create :user, company: company, team: child_team
        create_list :forecast_pipeline_fact, 2, forecast_time_dimension: forecast_time_dimension, 
                    user_dimension_id: other_user.id, amount: 300, stage_dimension_id: stage.id
        create_list :forecast_revenue_fact, 2, forecast_time_dimension: forecast_time_dimension, 
                    user_dimension_id: other_user.id, amount: 150
        team.update(leader_id: user.id)
      end

      it 'returns all parent and child team users' do
        expect(subject.length).to eq(2)
      end

      it 'sum child team members revenue and weighted_pipeline for parent team leader' do
        leader_data = subject.detect{|u| u[:is_leader]}
        expect(leader_data[:revenue]).to eq(550)
        expect(leader_data[:weighted_pipeline]).to eq(105)
      end
    end
  end

  describe 'generates quota atatinment report by user status' do
    before do
      user
      other_user = create :user, company: company, team: team, is_active: false
    end

    subject { quota_attainment_service.perform }

    context 'without user_status' do
      it 'returns all user data' do
        quota_attainment_service({time_period_id: time_period.id})
        expect(subject.length).to eq(2)
      end
    end

    context 'with all user_status' do
      it 'returns all user data' do
        quota_attainment_service({time_period_id: time_period.id, user_status: 'all'})
        expect(subject.length).to eq(2)
      end
    end

    context 'with active status' do
      it 'returns active user data' do
        quota_attainment_service({time_period_id: time_period.id, user_status: 'active'})
        expect(subject.length).to eq(1)
        expect(subject.first[:is_active]).to be true
      end
    end

    context 'with inactive status' do
      it 'returns inactive user data' do
        quota_attainment_service({time_period_id: time_period.id, user_status: 'inactive'})
        expect(subject.length).to eq(1)
        expect(subject.first[:is_active]).to be false
      end
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def time_period
    @_time_period ||= create :time_period, company: company
  end

  def team
    @_team ||= create :team, company: company
  end

  def user
    @_user ||= create :user, company: company, team: team
  end

  def forecast_time_dimension
    @_forecast_time_dimension ||= create :forecast_time_dimension, id: time_period.id
  end

  def forecast_revenue_fact
    create :forecast_revenue_fact, forecast_time_dimension: forecast_time_dimension, 
            user_dimension_id: user.id, amount: 100
    create :forecast_revenue_fact, forecast_time_dimension: forecast_time_dimension, 
            user_dimension_id: user.id, amount: 150
  end

  def stage
    @_stage ||= create :stage, company: company, probability: 10
  end

  def forecast_pipeline_fact
    create :forecast_pipeline_fact, forecast_time_dimension: forecast_time_dimension, 
            user_dimension_id: user.id, amount: 200, stage_dimension_id: stage.id
    create :forecast_pipeline_fact, forecast_time_dimension: forecast_time_dimension, 
            user_dimension_id: user.id, amount: 250, stage_dimension_id: stage.id
  end

  def quota
    @_quota ||= create :quota, user: user, company: company, time_period: time_period, value: 1100
  end

  def product
    @_product ||= create :product, company: company
  end

  def quota_attainment_service(params={})
    @_quota_attainment_service ||= described_class.new(company, params)
  end
end