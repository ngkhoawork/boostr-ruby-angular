require 'rails_helper'

describe Users::BaseSerializer do

  it 'serializes basic user data' do
    expect(serializer.id).to eq(user.id)
    expect(serializer.company_id).to eq(user.company_id)
    expect(serializer.email).to eq(user.email)
    expect(serializer.first_name).to eq(user.first_name)
    expect(serializer.last_name).to eq(user.last_name)
    expect(serializer.team_id).to eq(user.team_id)
    expect(serializer.is_leader).to eq(user.is_leader)
    expect(serializer.office).to eq(user.office)
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

  def user
    @_user ||= create :user, team: team
  end
end
