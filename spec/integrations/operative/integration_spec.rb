require 'rails_helper'

describe 'Integration', operative: true do
  before do
    create :billing_address_validation, company: company
    create :operative_api_configuration, company: company
    create :billing_deal_contact, deal: deal, contact: contact
  end

  context 'create order' do
    let(:response) { Operative::IntegrationService.new(deal.id).perform }
    let(:parsed_response) { Nokogiri::XML response.body }

    it 'expect to have proper response', vcr: true do
      expect(element_value_from_response('name')).to eq('Deal 1_235')
      expect(element_value_from_response('description')).to eq(deal_description)
      expect(element_value_from_response('currency')).to eq('USD')
      expect(element_value_from_response('alternateId')).to eq('boostr_235_Hammes, Block and Kilback_order')
      expect(element_value_from_response('nextSteps')).to eq('Call Somebody')
      expect(element_value_from_response('primarySalesperson')).to eq('jason.parmer@kingsandbox.com')
      expect(element_value_from_response('owner')).to eq('jason.parmer@kingsandbox.com')
      expect(element_value_from_response('salesStage/name')).to eq('10% - Sales lead')
      expect(element_value_from_response('salesOrderType/name')).to eq('Agency Buy')
      expect(element_value_from_response('accounts/account/id')).to include('170')
      expect(element_value_from_response('accounts/account/id')).to include('171')
      expect(element_value_from_response('accounts/account/externalId')).to include('boostr_747_Hammes, Block and Kilback_account')
      expect(element_value_from_response('accounts/account/externalId')).to include('boostr_746_Hammes, Block and Kilback_account')
      expect(element_value_from_response('accounts/account/contacts/contact/id')).to include('83')
      expect(element_value_from_response('accounts/account/contacts/contact/externalId')).to include('boostr_26_Hammes, Block and Kilback_contact')
    end
  end

  context 'update order' do
    before do
      deal.update(name: 'Deal updated')
      deal.integrations.create!(external_type: 'operative', external_id: 324)
      deal.agency.integrations.create!(external_type: 'operative', external_id: 170)
      deal.advertiser.integrations.create!(external_type: 'operative', external_id: 171)
      contact.integrations.create!(external_type: 'operative', external_id: 83)
    end

    let(:response) { Operative::IntegrationService.new(deal.id).perform }
    let(:parsed_response) { Nokogiri::XML response.body }

    it 'expect to have proper response', vcr: true do
      expect(element_value_from_response('name')).to eq('Deal updated_240')
    end
  end

  private

  def deal
    @_deal ||= create :deal,
                      creator: account_manager,
                      budget: 20_000,
                      advertiser: create_advertiser,
                      agency: create_agency,
                      company: company
  end

  def create_advertiser
    @_advertiser ||= create :client, company: company
  end

  def create_agency
    @_agency ||= create :client,
                        values: [create_agency_value],
                        company: company
  end

  def create_agency_value
    Value.create!(field_id: client_type_field_id, option_id: agency_option_id)
  end

  def contact
    @_contact ||= create :contact,
                         clients: [deal.advertiser],
                         company: company
  end

  def account_manager
    @_account_manager ||= create :user, email: 'jason.parmer@kingsandbox.com', user_type: ACCOUNT_MANAGER
  end

  def company
    @_company ||= create :company
  end

  def client_type_field
    @_client_type_field ||= company.fields.find_by(name: 'Client Type')
  end

  def client_type_field_id
    client_type_field.id
  end

  def agency_option_id
    client_type_field.options.find_by(name: 'Agency').id
  end

  def element_value_from_response(element)
    parsed_response.remove_namespaces!.xpath("/Collection/salesOrder/#{element}").text
  end

  def deal_description
    'Budget: $20,000.00, start date: Wednesday, 29 Jul 2015, end_date: Saturday, 29 Aug 2015'
  end
end
