require 'rails_helper'

RSpec.describe Value, type: :model do
  let(:company) { create :company }
  let(:field) { create :field, company: company }
  let(:option) { create :option, company: company, field: field }
  let(:deal) { create :deal, company: company }
  let(:value) { create :value, company: company, field: field, subject: deal, option: option }

  it "sets the value_type" do
    expect(value.value_type).to eq(field.value_type)
  end

  context "option values" do
    it "returns the option if it has the value_type Option" do
      value.value_type = 'Text'
      value.value_text = 'Taco'
      expect(value.value).to eq('Taco')
    end

    it "sets the option if it has the value_type Option" do
      value.value_type = 'Text'
      value.value = 'Taco'
      expect(value.value_text).to eq('Taco')
    end
  end

end
