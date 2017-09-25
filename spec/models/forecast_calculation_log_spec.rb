require 'rails_helper'

RSpec.describe ForecastCalculationLog, type: :model do
	context 'validation' do
		it { should validate_presence_of(:company_id) }
		it { should validate_presence_of(:start_date) }
	end
end
