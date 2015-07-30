require 'rails_helper'

RSpec.describe Client, 'validation' do
  it { should validate_presence_of(:name) }
end

RSpec.describe Client, 'association' do
  it { should have_many(:client_members) }
  it { should have_many(:users).through(:client_members) }
end
