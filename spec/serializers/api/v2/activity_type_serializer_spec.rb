require 'rails_helper'

RSpec.describe Api::V2::ActivityTypeSerializer do
  let!(:company) { create :company }
  subject { Api::V2::ActivityTypeSerializer.new(activity_type) }

  it "includes the expected attributes" do
    expect(subject.attributes.keys).
      to contain_exactly(
        :id,
        :action,
        :name,
        :icon,
        :position,
        :active,
        :css_class
      )
  end

  it 'returns item values' do
    expect(subject.attributes.values).
      to contain_exactly(
        activity_type.id,
        activity_type.name,
        activity_type.action,
        activity_type.icon,
        activity_type.position,
        activity_type.active,
        activity_type.css_class
      )
  end

  def activity_type
    @_activity_type ||= create(:activity_type)
  end
end
