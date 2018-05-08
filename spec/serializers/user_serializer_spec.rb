require 'rails_helper'

describe UserSerializer do

  it 'serializes user data' do
    expect(serializer.id).to eq(user.id)
    expect(serializer.company_id).to eq(user.company_id)
    expect(serializer.email).to eq(user.email)
    expect(serializer.first_name).to eq(user.first_name)
    expect(serializer.last_name).to eq(user.last_name)
    expect(serializer.team_id).to eq(user.team_id)
    expect(serializer.is_leader).to eq(user.is_leader)
    expect(serializer.office).to eq(user.office)
    expect(serializer.is_legal).to eq(user.is_legal)
    expect(serializer.default_currency).to eq(user.default_currency)
    expect(serializer.roles_mask).to eq(user.roles_mask)
    expect(serializer.cycle_time).to eq(user.cycle_time)
    expect(serializer.is_active).to eq(user.is_active)
    expect(serializer.is_admin).to eq(user.is_admin)
    expect(serializer.employee_id).to eq(user.employee_id)
    expect(serializer.leads_enabled).to eq(user.leads_enabled)
    expect(serializer.user_type).to eq(user.user_type)
    expect(serializer.revenue_requests_access).to eq(user.revenue_requests_access)
    expect(serializer.title).to eq(user.title)
    expect(serializer.contracts_enabled).to eq(user.contracts_enabled)
    expect(serializer.teams).to eq(user_teams)
    expect(serializer.team).to eq(user_team)
  end

  private

  def serializer
    @_serializer ||= described_class.new(user)
  end

  def company
    @_company ||= create :company
  end

  def leader
    @_leader ||= create :user
  end

  def team
    @_team ||= create :team, leader: leader
  end

  def user_teams
    TeamSerializer.new(user.teams).object
  end

  def user_team
    TeamSerializer.new(user.team).object
  end

  def user
    @_member ||= create :user, team: team
  end
end
