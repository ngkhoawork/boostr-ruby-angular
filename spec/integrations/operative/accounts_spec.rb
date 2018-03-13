require 'rails_helper'

describe 'Accounts integration', operative: true do
  before do
    create :billing_address_validation, company: company
    create :billing_deal_contact, deal: deal, contact: contact
 end

  describe 'agency' do
    context 'create agency' do
      let(:response) { Operative::AccountsService.new(agency, auth_details, deal.id).perform }
      let(:parsed_response) { Nokogiri::XML response.body }

      it 'expect to have proper response', vcr: true do
        expect(element_value_from_response('accountId')).to eq('169')
        expect(element_value_from_response('name')).to eq('Pfannerstill-Oberbrunner')
        expect(element_value_from_response('phone')).to eq('69985740331568')
        expect(element_value_from_response('addressline1')).to eq('9124 Madyson Cliff')
        expect(element_value_from_response('addressline2')).to eq('Apt. 907')
        expect(element_value_from_response('city')).to eq('New Murphybury')
        expect(element_value_from_response('state')).to eq('WV')
        expect(element_value_from_response('zip')).to eq('85703')
        expect(element_value_from_response('country')).to eq('Mongolia')
        expect(element_value_from_response('externalID')).to eq('boostr_288_Gerlach LLC_account')
        expect(element_value_from_response('accountType/@name')).to eq('agency')
      end
    end

    context 'update agency' do
      before do
        agency.update(name: 'Joe Doe')
        agency.address.update(phone: '38093123454', zip: '12345')
        agency.integrations.create!(external_type: 'operative', external_id: 169)
      end

      let(:response) { Operative::AccountsService.new(agency, auth_details, deal.id).perform }
      let(:parsed_response) { Nokogiri::XML response.body }

      it 'expect to have proper response', vcr: true do
        expect(element_value_from_response('name')).to eq('Joe Doe')
        expect(element_value_from_response('phone')).to eq('38093123454')
        expect(element_value_from_response('zip')).to eq('12345')
      end
    end
  end

  describe 'advertiser' do
    context 'create advertiser' do
      let(:response) { Operative::AccountsService.new(advertiser, auth_details, deal.id).perform }
      let(:parsed_response) { Nokogiri::XML response.body }

      it 'expect to have proper response', vcr: true do
        expect(element_value_from_response('accountId')).to eq('167')
        expect(element_value_from_response('name')).to eq('Berge-Cole')
        expect(element_value_from_response('phone')).to eq('60684764867771')
        expect(element_value_from_response('addressline1')).to eq('42935 Huel Cliffs')
        expect(element_value_from_response('addressline2')).to eq('Suite 931')
        expect(element_value_from_response('city')).to eq('South Orlando')
        expect(element_value_from_response('state')).to eq('PA')
        expect(element_value_from_response('zip')).to eq('43460')
        expect(element_value_from_response('country')).to eq('El Salvador')
        expect(element_value_from_response('externalID')).to eq('boostr_190_Osinski, Boyer and Konopelski_account')
        expect(element_value_from_response('accountType/@name')).to eq('advertiser')
      end
    end

    context 'update advertiser' do
      before do
        advertiser.update(name: 'Joe Doe')
        advertiser.address.update(phone: '38093123454', zip: '12345')
        advertiser.integrations.create!(external_type: 'operative', external_id: 167)
      end

      let(:response) { Operative::AccountsService.new(advertiser, auth_details, deal.id).perform }
      let(:parsed_response) { Nokogiri::XML response.body }

      it 'expect to have proper response', vcr: true do
        expect(element_value_from_response('name')).to eq('Joe Doe')
        expect(element_value_from_response('phone')).to eq('38093123454')
        expect(element_value_from_response('zip')).to eq('12345')
      end
    end
  end

  def deal
    @_deal ||= create :deal, creator: account_manager, budget: 20_000, agency: create_agency, company: company
  end

  def account_manager
    @_account_manager ||= create :user, email: 'test@email.com', user_type: ACCOUNT_MANAGER
  end

  def company
    @_company ||= create :company
  end

  def create_agency
    create :client, values: [create_agency_value]
  end

  def create_agency_value
    Value.create!(field_id: client_type_field_id, option_id: agency_option_id)
  end

  def agency
    deal.agency
  end

  def advertiser
    deal.advertiser
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

  def client_type_field
    @_client_type_field ||= company.fields.find_by(name: 'Client Type')
  end

  def client_type_field_id
    client_type_field.id
  end

  def agency_option_id
    client_type_field.options.find_by(name: 'Agency').id
  end

  def contact
    @_contact ||= create :contact,
                         clients: [deal.advertiser],
                         company: company
  end
end
