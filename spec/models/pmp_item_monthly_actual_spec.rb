require 'rails_helper'

RSpec.describe PmpItemMonthlyActual, 'validations' do
  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:amount_loc) }
end

RSpec.describe PmpItemMonthlyActual, 'associations' do
  it { should belong_to(:pmp_item) }
end