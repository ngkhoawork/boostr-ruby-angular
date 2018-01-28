require 'rails_helper'

describe Csv::AccountsService do
  subject(:csv_report) { described_class.new(accounts_relation, company).perform }

  let(:report_default_headers) { Csv::AccountsService.default_headers.join(',') }

  it { is_expected.to_not be_nil }
  it 'includes report\'s default headers' do
    expect(csv_report).to match report_default_headers
  end
  it 'includes account\'s attributes' do
    expect(csv_report).to include account.id.to_s
    expect(csv_report).to include account.name
  end

  private

  def accounts_relation
    @_accounts_relation ||= Client.where(id: account.id)
  end

  def company
    @_company ||= Company.first
  end

  def account
    @_account ||= create(:client, :advertiser, company: company)
  end
end
