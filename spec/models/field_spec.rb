require 'rails_helper'

RSpec.describe Field, type: :model do
  let(:company) { create :company }
  let(:field) { create :field, company: company }
  let(:option) { create :option, company: company, field: field }
  let(:deal) { create :deal, company: company }
  let(:value) { create :value, company: company, field: field, subject: deal, option: option }

  context "validations" do
    it "validates the value_type" do
      expect(field).to be_valid
      field.value_type = "Horse"
      expect(field).to be_invalid
      field.value_type = "Object"
      expect(field).to be_valid
    end
  end

  context "json" do
    it "includes the options in the json" do
      option
      expect(field.as_json["options"][0]["id"]).to eq(option.id)
    end
  end
end
