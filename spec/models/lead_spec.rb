require 'rails_helper'

describe 'Lead' do
  describe 'scopes' do
    it '#new_records' do
      create_list :lead, 5, company: company, user: user, status: Lead::NEW

      expect(Lead.new_records.count).to eq 5
    end

    it '#accepted' do
      create_list :lead, 3, company: company, status: Lead::ACCEPTED, user: user

      expect(Lead.accepted.count).to eq 3
    end

    it '#rejected' do
      create_list :lead, 4, company: company, status: Lead::REJECTED, user: user

      expect(Lead.rejected.count).to eq 4
    end

    it '#by_company_id' do
      create_list :lead, 5, company: company, user: user

      expect(Lead.by_company_id(company.id).count).to eq 5
    end
  end

  describe 'callbacks' do
    let!(:product) { create :product, company: company, name: 'Display' }
    let!(:contact) { create :contact, address: create(:address, email: 'test@gmail.com') }

    before { create :assignment_rules_user, user: user, assignment_rule: assignment_rule, next: true }

    it 'map product to lead' do
      lead = create :lead, product_name: 'Display', company: company

      expect(lead.product_id).to eq product.id
    end

    it 'map contact with lead' do
      lead = create :lead, product_name: 'Display', company: company, email: 'test@gmail.com'

      expect(lead.contact_id).to eq contact.id
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def assignment_rule
    create :assignment_rule,
           name: 'Product Test',
           default: false,
           company: company,
           field_type: AssignmentRule::PRODUCT_NAME,
           criteria_1: ['Display']
  end
end
