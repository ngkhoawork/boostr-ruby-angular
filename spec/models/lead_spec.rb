require 'rails_helper'

describe 'Lead' do
  describe 'scopes' do
    it '#new_records' do
      create_list :lead, 5, company: company

      expect(Lead.new_records.count).to eq 5
    end

    it '#accepted' do
      create_list :lead, 3, company: company, status: Lead::ACCEPTED

      expect(Lead.accepted.count).to eq 3
    end

    it '#rejected' do
      create_list :lead, 4, company: company, status: Lead::REJECTED

      expect(Lead.rejected.count).to eq 4
    end
  end

  private

  def company
    @_company ||= create :company
  end
end
