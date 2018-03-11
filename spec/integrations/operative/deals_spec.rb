require 'rails_helper'

describe 'Deals integration', operative: true do
  before do
    create :billing_address_validation, company: company
    create :billing_deal_contact, deal: deal, contact: contact
 end

  context 'create deal' do
    let(:response) { Operative::DealsService.new(deal, false, auth_details).perform }
    let(:parsed_response) { Nokogiri::XML response.body }

    it 'expect to have proper response', vcr: true do
      expect(element_value_from_response('name')).to eq('Deal 1_181')
      expect(element_value_from_response('description')).to eq(deal_description)
      expect(element_value_from_response('currency')).to eq('USD')
      expect(element_value_from_response('alternateId')).to eq('boostr_181_Zulauf LLC_order')
      expect(element_value_from_response('nextSteps')).to eq('Call Somebody')
      expect(element_value_from_response('primarySalesperson')).to eq('jason.parmer@kingsandbox.com')
      expect(element_value_from_response('owner')).to eq('jason.parmer@kingsandbox.com')
      expect(element_value_from_response('salesStage/name')).to eq('10% - Sales lead')
      expect(element_value_from_response('salesOrderType/name')).to eq('Agency Buy')
    end
  end

  context 'update deal' do
    before do
      deal.update(name: 'Deal updated')
      deal.integrations.create!(external_type: 'operative', external_id: 323)
      deal.agency.integrations.create!(external_type: 'operative', external_id: 169)
      deal.advertiser.integrations.create!(external_type: 'operative', external_id: 167)
      contact.integrations.create!(external_type: 'operative', external_id: 82)
    end

    let(:response) { Operative::DealsService.new(deal, false, auth_details).perform }
    let(:parsed_response) { Nokogiri::XML response.body }

    it 'expect to have proper response', vcr: true do
      expect(element_value_from_response('name')).to eq('Deal updated_202')
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
    @_advertiser ||= create :client, name: 'Joan Doe', id: 270, company: company
  end

  def create_agency
    @_agency ||= create :client,
                        values: [create_agency_value],
                        name: 'Joe Doe',
                        id: 308,
                        company: agency_company
  end

  def create_agency_value
    Value.create!(field_id: client_type_field_id, option_id: agency_option_id)
  end

  def contact
    @_contact ||= create :contact,
                         clients: [deal.advertiser],
                         name: 'John Doe',
                         id: 11,
                         company: contact_company
  end

  def account_manager
    @_account_manager ||= create :user, email: 'jason.parmer@kingsandbox.com', user_type: ACCOUNT_MANAGER
  end

  def company
    @_company ||= create :company, name: 'Zulauf LLC'
  end

  def agency_company
    @_agency_company ||= create :company, name: 'Reilly, Turcotte and D\'Amore'
  end

  def contact_company
    @_contact_company ||= create :company, name: 'Kassulke LLC'
  end

  def auth_details
    @_auth_details ||= {
      base_url: 'https://config.operativeone.com',
      user_email: 'api_user@kingsandbox.com',
      password: 'King2017!',
      company_id: company.id
    }
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
