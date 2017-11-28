require 'rails_helper'

RSpec.describe PmpItemDailyActual, 'validations' do
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:price) }
  it { should validate_presence_of(:revenue) }
  it { should validate_presence_of(:impressions) }
  it { should validate_presence_of(:win_rate) }
  it { should validate_presence_of(:bids) }
end

RSpec.describe PmpItemDailyActual, 'associations' do
  it { should belong_to(:pmp_item) }
end