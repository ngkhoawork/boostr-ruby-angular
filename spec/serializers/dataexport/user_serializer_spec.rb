require 'rails_helper'

describe Dataexport::UserSerializer do
  it 'serializes user data' do
    expect(serializer.id).to eq(user.id)
    expect(serializer.first_name).to eq(user.first_name)
    expect(serializer.last_name).to eq(user.last_name)
    expect(serializer.email).to eq(user.email)
    expect(serializer.office).to eq(user.office)
    expect(serializer.employee_id).to eq(user.employee_id)
    expect(serializer.currency).to eq(user.default_currency)
    expect(serializer.active).to eq(user.is_active)
    expect(serializer.created).to eq(user.created_at)
    expect(serializer.last_updated).to eq(user.updated_at)
  end

  private

  def serializer
    @_serializer ||= described_class.new(user)
  end

  def user
    @_user ||= create :user, company: company
  end

  def company
    @_company ||= create :company
  end
end
