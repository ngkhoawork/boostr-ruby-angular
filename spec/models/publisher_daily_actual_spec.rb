require 'rails_helper'

RSpec.describe PublisherDailyActual, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:available_impressions) }
    it { is_expected.to validate_presence_of(:filled_impressions) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:publisher) }
  end
end
