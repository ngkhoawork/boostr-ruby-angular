require 'rails_helper'

RSpec.describe PmpItemDailyActual, 'validations' do
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:ad_unit) }
  it { should validate_presence_of(:ad_requests) }
  it { should validate_presence_of(:impressions) }
  it { should validate_presence_of(:revenue_loc) }
  it { should validate_presence_of(:price) }
  it { should validate_numericality_of(:ad_requests) }
  it { should validate_numericality_of(:impressions) }
  it { should validate_numericality_of(:revenue_loc) }
  it { should validate_numericality_of(:price) }
  it { should validate_numericality_of(:render_rate) }
  it { should allow_value(nil).for(:render_rate) }
end

RSpec.describe PmpItemDailyActual, 'associations' do
  it { should belong_to(:pmp_item) }
end