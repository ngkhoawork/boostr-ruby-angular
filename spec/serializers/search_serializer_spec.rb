require 'rails_helper'

describe SearchSerializer do
  it 'serializer deal search data' do
    expect(deal_serializer['id']).to eq(deal.id)
    expect(deal_serializer['name']).to eq('test deal')
    expect(deal_serializer['budget']).to eq(deal.budget)
    expect(deal_serializer['budget_loc']).to eq(deal.budget_loc)
    expect(deal_serializer['start_date']).to eq(deal.start_date.strftime('%Y-%m-%d'))
    expect(deal_serializer['end_date']).to eq(deal.end_date.strftime('%Y-%m-%d'))
    expect(deal_serializer['advertiser']['name']).to eq('test advertiser')
    expect(deal_serializer['agency']['name']).to eq('test agency')
    expect(deal_serializer['stage']['name']).to eq('initial')
    expect(deal_serializer['stage']['probability']).to eq(0)
  end

  it 'serializer io search data' do
    expect(io_serializer['id']).to eq(io.id)
    expect(io_serializer['io_number']).to eq(io.io_number)
    expect(io_serializer['name']).to eq('test io')
    expect(io_serializer['budget']).to eq(io.budget)
    expect(io_serializer['budget_loc']).to eq(io.budget_loc)
    expect(io_serializer['start_date']).to eq(io.start_date.strftime('%Y-%m-%d'))
    expect(io_serializer['end_date']).to eq(io.end_date.strftime('%Y-%m-%d'))
    expect(io_serializer['advertiser']['name']).to eq('test advertiser')
    expect(io_serializer['agency']['name']).to eq('test agency')
  end

  it 'serializer contact search data' do
    expect(contact_serializer['id']).to eq(contact.id)
    expect(contact_serializer['name']).to eq('test contact')
    expect(contact_serializer['position']).to eq(contact.position)
    expect(contact_serializer['email']).to eq(contact.email)
    expect(contact_serializer['clients'].first['name']).to eq('test advertiser')
  end

  it 'serializer client search data' do
    create :client_member, client: advertiser, user: user
    expect(client_serializer['id']).to eq(advertiser.id)
    expect(client_serializer['name']).to eq('test advertiser')
    expect(client_serializer['client_type']['name']).to eq(advertiser.client_type.name)
    expect(client_serializer['client_category']).to eq(nil)
    expect(client_serializer['client_members'].first['name']).to eq('test user')
  end

  private

  def client_serializer
    @_client_serializer ||= JSON.parse(described_class.new(advertiser.pg_search_document).to_json)['details']
  end

  def user
    @_user ||= create :user, first_name: 'test', last_name: 'user'
  end

  def contact_serializer
    @_contact_serializer ||= JSON.parse(described_class.new(contact.pg_search_document).to_json)['details']
  end

  def contact
    @_contact ||= create :contact, name: 'test contact', company: company, client: advertiser
  end

  def io_serializer
    @_io_serializer ||= JSON.parse(described_class.new(io.pg_search_document).to_json)['details']
  end

  def io
    @_io ||= create :io, company: company, name: 'test io', advertiser: advertiser, agency: agency
  end

  def deal_serializer
    @_deal_serializer ||= JSON.parse(described_class.new(deal.pg_search_document).to_json)['details']
  end

  def deal
    @_deal ||= create :deal, company: company, name: 'test deal', advertiser: advertiser, agency: agency, stage: stage
  end

  def agency
    @_agency ||= create :client, :agency, company: company, name: 'test agency'
  end

  def advertiser
    @_advertiser ||= create :client, :advertiser, company: company, name: 'test advertiser'
  end

  def stage
    @_stage ||= create :stage, company: company, name: 'initial', probability: 0
  end

  def company
    @_company ||= create :company
  end
end
