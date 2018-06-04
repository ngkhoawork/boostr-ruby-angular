require 'rails_helper'

describe Teams::IndexSerializer do
  before do
    member1
    member2
    child_team1
    child_team2
  end

  it 'serializes user data' do
    expect(serializer.id).to eq(team.id)
    expect(serializer.name).to eq('West Team')
    expect(serializer.leader_id).to eq(leader.id)
    expect(serializer.parent_id).to eq(parent_team.id)
    expect(serializer.sales_process_id).to eq(sales_process.id)
    expect(serializer.members_count).to eq(2)
    expect(serializer.leader_name).to eq('John Doe')
    expect(serializer.leader).to eq(leader_serializer)
    expect(serializer.members.count).to eq(2)
    expect(serializer.members).to include(member1_serializer)
    expect(serializer.members).to include(member2_serializer)
    expect(serializer.parent).to eq(parent_serializer)
    expect(serializer.children.count).to eq(2)
    expect(serializer.children).to include(child_team1_serializer)
    expect(serializer.children).to include(child_team2_serializer)
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

  def leader_serializer
    UserSerializer.new(leader).object
  end

  def parent_serializer
    TeamSerializer.new(parent_team).object
  end

  def member1_serializer
    UserSerializer.new(member1).object
  end

  def member2_serializer
    UserSerializer.new(member2).object
  end

  def child_team1_serializer
    Teams::ChildSerializer.new(child_team1).object
  end

  def child_team2_serializer
    Teams::ChildSerializer.new(child_team2).object
  end

  def child_team1
    @_child_team1 ||= create :team, company: company, parent: team
  end

  def child_team2
    @_child_team2 ||= create :team, company: company, parent: team
  end

  def parent_team
    @_parent_team ||= create :team, company: company
  end

  def sales_process
    @_sales_process ||= create :sales_process, company: company
  end

  def member1
    @_member1 ||= create :user, company: company, team: team
  end

  def member2
    @_member2 ||= create :user, company: company, team: team
  end

  def team
    @_team ||= create :team,  company: company,
                              name: 'West Team',
                              parent: parent_team,
                              leader: leader,
                              sales_process: sales_process
  end
end
