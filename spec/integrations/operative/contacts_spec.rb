require 'rails_helper'

describe 'Contacts integration', operative: true do
  before do
    create :billing_address_validation, company: company
    create :billing_deal_contact, deal: deal, contact: contact
  end

  context 'create contact' do
    let(:response) { Operative::ContactsService.new(contact, advertiser_name, auth_details, deal.id).perform }
    let(:parsed_response) { Nokogiri::XML response.body }

    it 'expect to have proper response', vcr: true do
      expect(element_value_from_response('contactId')).to eq('82')
      expect(element_value_from_response('account/@name')).to eq('Joe Doe')
      expect(element_value_from_response('firstname')).to eq('Myles')
      expect(element_value_from_response('lastname')).to eq('Huel')
      expect(element_value_from_response('email')).to eq('yasmin_jewess@ritchie.name')
      expect(element_value_from_response('phone')).to eq('61871375712228')
      expect(element_value_from_response('mobile')).to eq('19397917000225')
      expect(element_value_from_response('addressline1')).to eq('3212 Gudrun Junctions')
      expect(element_value_from_response('addressline2')).to eq('Apt. 052')
      expect(element_value_from_response('city')).to eq('Port Amanihaven')
      expect(element_value_from_response('state')).to eq('NV')
      expect(element_value_from_response('zip')).to eq('41460')
      expect(element_value_from_response('country')).to eq('Botswana')
      expect(element_value_from_response('externalID')).to eq('boostr_7_Jones and Sons_contact')
    end
  end

  context 'update contact' do
    before do
      contact.update(name: 'John Doe')
      contact.address.update(phone: '38093123454', zip: '12345')
      contact.integrations.create!(external_type: 'operative', external_id: 82)
    end

    let(:response) { Operative::ContactsService.new(contact, advertiser_name, auth_details, deal.id).perform }
    let(:parsed_response) { Nokogiri::XML response.body }

    it 'expect to have proper response', vcr: true do
      expect(element_value_from_response('firstname')).to eq('John')
      expect(element_value_from_response('lastname')).to eq('Doe')
      expect(element_value_from_response('phone')).to eq('38093123454')
      expect(element_value_from_response('zip')).to eq('12345')
    end
  end

  private

  def deal
    @_deal ||= create :deal, creator: account_manager, budget: 20_000, company: company
  end

  def company
    @_company ||= create :company
  end

  def account_manager
    @_account_manager ||= create :user, email: 'test@email.com', user_type: ACCOUNT_MANAGER
  end

  def contact
    @_contact ||= create :contact,
                         clients: [deal.advertiser],
                         company: company
  end

  def advertiser_name
    'Joe Doe'
  end

  def auth_details
    @_auth_details ||= {
      base_url: 'https://config.operativeone.com',
      user_email: 'api_user@kingsandbox.com',
      password: 'King2017!',
      company_id: company.id
    }
  end

  def element_value_from_response(element)
    parsed_response.xpath("//#{element}").text
  end
end
