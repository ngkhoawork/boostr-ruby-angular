require 'rails_helper'

describe Operative::Deals::Single do
  it 'has proper mapped value' do
    expect(deal_mapper).to include deal_name
    expect(deal_mapper).to include deal.id.to_s
    expect(deal_mapper).to include deal.next_steps
    expect(deal_mapper).to include deal_description
    expect(deal_mapper).to include 'Agency Buy'
    expect(deal_mapper).to include deal.stage.name
    expect(deal_mapper).to include deal_agency
    expect(deal_mapper).to include deal_advertiser
    expect(deal_mapper).to include user.email
    expect(deal_mapper).to include second_user.email
  end

  private

  def deal
    @_deal ||= create :deal, creator: user, budget: 20_000, deal_members: [deal_member]
  end

  def deal_mapper
    @_deal_mapper ||= described_class.new(deal).to_xml
  end

  def deal_name
    "#{deal.name}_#{deal.id}"
  end

  def user
    @_user ||= create :user, email: 'test@email.com'
  end

  def second_user
    @_second_user ||= create :user, email: 'second_test@email.com'
  end

  def deal_description
    "Budget: $20,000.00, start date: #{deal_start_date}, end_date: #{deal_end_date}"
  end

  def deal_agency
    "<externalId>#{deal.agency_id}</externalId>"
  end

  def deal_advertiser
    "<externalId>#{deal.advertiser_id}</externalId>"
  end

  def deal_start_date
    deal.start_date.strftime('%A, %d %b %Y')
  end

  def deal_end_date
    deal.end_date.strftime('%A, %d %b %Y')
  end

  def deal_member
    create(:deal_member, user: second_user)
  end
end
