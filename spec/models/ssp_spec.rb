require 'rails_helper'

RSpec.describe Ssp, 'validations' do
  it { should validate_presence_of(:name) }
end