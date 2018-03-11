require 'rails_helper'

describe Pmps::PmpMemberSerializer do
  let!(:company) { create :company, :fast_create_company }
  it 'serialize pmp_member' do
    expect(serializer.id).to eq(pmp_member.id)
    expect(serializer.user_id).to eq(pmp_member.user_id)
    expect(serializer.pmp_id).to eq(pmp_member.pmp_id)
    expect(serializer.name).to eq(pmp_member.user.name)
    expect(serializer.share).to eq(pmp_member.share)
    expect(serializer.from_date).to eq(pmp_member.from_date)
    expect(serializer.to_date).to eq(pmp_member.to_date)
    expect(serializer.user.symbolize_keys).to eq(id: pmp_member.user.id, email: pmp_member.user.email)
  end

  describe 'without user' do
    it 'returns nil for name and user keys' do
      pmp_member.user = nil
      serializer = described_class.new(pmp_member)
      expect(serializer.name).to eq(nil)
      expect(serializer.user).to eq(nil)
    end
  end

  private

  def serializer
    @_serializer ||= described_class.new(pmp_member)
  end

  def pmp_member
    @_pmp_member ||= create :pmp_member
  end
end