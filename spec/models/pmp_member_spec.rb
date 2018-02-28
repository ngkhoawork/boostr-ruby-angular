require 'rails_helper'

RSpec.describe PmpMember, 'validations' do
  it { should validate_presence_of(:share) }
  it { should validate_presence_of(:from_date) }
  it { should validate_presence_of(:to_date) }
end

RSpec.describe PmpMember, 'associations' do
  it { should belong_to(:pmp) }
  it { should belong_to(:user) }
end