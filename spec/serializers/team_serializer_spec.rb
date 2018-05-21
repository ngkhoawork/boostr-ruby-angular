require 'rails_helper'

describe TeamSerializer do
  before do
    member1
    member2
  end
  it 'serializes user data' do
    expect(serializer.id).to eq(team.id)
    expect(serializer.name).to eq('West Team')
    expect(serializer.leader_id).to eq(leader.id)
    expect(serializer.parent_id).to eq(parent_team.id)
    expect(serializer.sales_process_id).to eq(sales_process.id)
    expect(serializer.members_count).to eq(2)
    expect(serializer.leader_name).to eq('John Doe')
  end

  private

  def serializer
    @_serializer ||= described_class.new(team)
  end

  def company
    @_company ||= create :company
  end

  def leader
    @_leader ||= create :user, first_name: 'John', last_name: 'Doe'
  end

  def parent_team
    @_parent_team ||= create :team, company: company
  end

  def sales_process
    @_sales_process ||= create :sales_process, company: company
  end

  def member1
    create :user, company: company, team: team
  end

  def member2
    create :user, company: company, team: team
  end

  def team
    @_team ||= create :team,  company: company,
                              name: 'West Team',
                              parent: parent_team,
                              leader: leader,
                              sales_process: sales_process
  end
end
