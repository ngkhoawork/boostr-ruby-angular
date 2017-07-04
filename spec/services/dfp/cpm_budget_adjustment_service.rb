require 'rails_helper'

RSpec.describe DFP::CpmBudgetAdjustmentService, dfp: :true do
  subject(:subject) {
    DFP::CpmBudgetAdjustmentService.new(company_id: company.id)
  }

  let(:company) { create(:company) }
  let(:dfp_api_configuration) { create(:dfp_api_configuration, json_api_key: { some_key: '' }, company: company) }
  let(:field_to_adjust) { 10_000_00 }
  let!(:cpm_budget_adjustment) { create(:cpm_budget_adjustment, percentage: 10.00, api_configuration_id: dfp_api_configuration.id) }

  it 'adjusts values by adjustment factor' do
    expect(subject.perform(field_to_adjust)).to eq(field_to_adjust * (100 - cpm_budget_adjustment.percentage) / 100)
  end

end
