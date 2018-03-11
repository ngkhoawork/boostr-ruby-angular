require 'rails_helper'

RSpec.describe Api::V1::ActivityTypeSerializer do
  let!(:company) { create :company, :fast_create_company }
  subject { Api::V1::ActivityTypeSerializer.new(activity_type) }

  it "includes the expected attributes" do
    expect(subject.attributes.keys).
      to contain_exactly(
        :id,
        :action,
        :name,
        :icon
      )
  end

  it 'returns item values' do
    expect(subject.attributes.values).
      to contain_exactly(
        activity_type.id,
        activity_type.name,
        activity_type.action,
        activity_type.icon
      )
  end

  def activity_type
    @_activity_type ||= create(:activity_type)
  end
end
