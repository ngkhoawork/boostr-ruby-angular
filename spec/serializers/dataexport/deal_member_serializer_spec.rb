require 'rails_helper'

describe Dataexport::DealMemberSerializer do
  it 'serializes deal_member data' do
    expect(serializer.user_id).to eq(deal_member.user_id)
    expect(serializer.share).to eq(deal_member.share)
    expect(serializer.role).to eq(deal_member.role)
  end

  private

  def serializer
    @_serializer ||= described_class.new(deal_member)
  end

  def deal_member
    @_deal_member ||= create :deal_member, user: user
  end

  def user
    @_user ||= create :user
  end
end
