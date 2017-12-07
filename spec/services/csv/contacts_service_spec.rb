require 'rails_helper'

describe Csv::ContactsService do
  subject(:csv_report) { described_class.new(company, Contact.all).perform }

  let(:company) { create :company }
  let!(:contact) { create :contact }

  it 'generates contacts CSV report' do
    is_expected.to_not be_nil
  end
end
