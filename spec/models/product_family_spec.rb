require 'rails_helper'

RSpec.describe ProductFamily, 'validation' do
  it { should validate_presence_of(:name) }
end

RSpec.describe ProductFamily, 'association' do
  it { should belong_to(:company) }
end