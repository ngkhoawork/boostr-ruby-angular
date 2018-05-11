require 'rails_helper'

describe Users::BaseSerializer do
  it 'serializes basic user data' do
    expect(serializer.id).to eq(user.id)
    expect(serializer.company_id).to eq(company.id)
    expect(serializer.email).to eq('john.doe@boostr.com')
    expect(serializer.first_name).to eq('John')
    expect(serializer.last_name).to eq('Doe')
    expect(serializer.name).to eq('John Doe')
    expect(serializer.team_id).to eq(team.id)
    expect(serializer.is_leader).to eq(false)
    expect(serializer.office).to eq('office 1')
  end

  private

  def serializer
    @_serializer ||= described_class.new(user)
  end

  def company
    @_company ||= create :company
  end

  def leader
    create :user, company: company
  end

  def team
    @_team ||= create :team, leader: leader
  end

  def user
    @_user ||= create :user,  company: company,
                                team: team,
                                first_name: 'John',
                                last_name: 'Doe',
                                email: 'john.doe@boostr.com',
                                office: 'office 1'
  end
end
