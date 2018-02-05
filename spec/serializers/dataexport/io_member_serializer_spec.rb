require 'rails_helper'

describe Dataexport::IoMemberSerializer do
  it 'serializes io_member data' do
    expect(serializer.id).to eq(io_member.id)
    expect(serializer.io_id).to eq(io_member.io_id)
    expect(serializer.user_id).to eq(io_member.user_id)
    expect(serializer.share).to eq(io_member.share)
    expect(serializer.from_date).to eq(io_member.from_date)
    expect(serializer.to_date).to eq(io_member.to_date)
    expect(serializer.created).to eq(io_member.created_at)
    expect(serializer.last_updated).to eq(io_member.updated_at)
  end

  private

  def serializer
    @_serializer ||= described_class.new(io_member)
  end

  def io_member
    @_io_member ||= create :io_member, io: io, user: user
  end

  def io
    @_io ||= create :io, company: company
  end

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end
end
