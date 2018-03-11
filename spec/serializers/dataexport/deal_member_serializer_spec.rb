require 'rails_helper'

describe Dataexport::DealMemberSerializer do
  let!(:company) { create :company, :fast_create_company }
  before { role }

  it 'serializes deal_member data' do
    expect(serializer.user_id).to eq(deal_member.user_id)
    expect(serializer.share).to eq(deal_member.share)
    expect(serializer.role).to eq(role)
    expect(serializer.created).to eq(deal_member.created_at)
    expect(serializer.last_updated).to eq(deal_member.updated_at)
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

  def role
    return @_role if defined? @_role

    field = deal_member.fields.find_or_initialize_by(subject_type: 'Client', name: 'Member Role', value_type: 'Option', locked: true)
    create_value_for_field(field)

    @_role = deal_member.values.find_by(field_id: field.id).option.name
  end

  def create_value_for_field(field)
    option = create :option, field: field, name: 'Option1'
    value = create :value, subject: deal_member, option: option, field: field
  end
end
