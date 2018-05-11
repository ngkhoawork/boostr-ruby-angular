require 'rails_helper'

describe UserSerializer do
  it 'serializes user data' do
    expect(serializer.id).to eq(user.id)
    expect(serializer.is_legal).to eq(true)
    expect(serializer.default_currency).to eq('USD')
    expect(serializer.roles_mask).to eq(7)
    expect(serializer.cycle_time).to eq(45.2)
    expect(serializer.is_active).to eq(true)
    expect(serializer.is_admin).to eq(true)
    expect(serializer.employee_id).to eq('223')
    expect(serializer.leads_enabled).to eq(true)
    expect(serializer.user_type).to eq(6)
    expect(serializer.revenue_requests_access).to eq(true)
    expect(serializer.title).to eq('title')
    expect(serializer.contracts_enabled).to eq(true)
    expect(serializer.teams).to eq(teams)
    expect(serializer.team).to eq(user_team)
  end

  private

  def serializer
    @_serializer ||= described_class.new(user)
  end

  def company
    create :company
  end

  def leader
    create :user
  end

  def team
    @_team ||= create :team, leader: leader
  end

  def teams
    TeamSerializer.new(user.teams).object
  end

  def user_team
    TeamSerializer.new(team).object
  end

  def user
    @_user ||= create :user,  company: company,
                              team: team,
                              is_legal: true,
                              cycle_time: 45.2,
                              is_active: true,
                              employee_id: '223',
                              leads_enabled: true,
                              title: 'title',
                              contracts_enabled: true,
                              revenue_requests_access: true,
                              user_type: 6,
                              roles_mask: 7
  end
end
