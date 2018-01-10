require 'rails_helper'

describe Operative::CustomFieldsRepresenter, operative: true do
  before do
    create :deal_custom_field_name,
           company: company,
           field_index: 1,
           field_type: "dropdown",
           field_label: "Territory Campaign Will Run In"

    create :deal_custom_field_name,
           company: company,
           field_index: 3,
           field_type: "text",
           field_label: "Billing Notes"

    create :deal_custom_field_name,
           company: company,
           field_index: 5,
           field_type: "dropdown",
           field_label: "BuzzFeed Signing Entity"
  end

  describe 'for buzzfeed deal' do
    it 'has proper mapped buzzfeed fields' do
      deal_custom_field
      expect(deal_mapper).to include buzzfeed_billing_note
      expect(deal_mapper).to include buzzfeed_campaign_territory
      expect(deal_mapper).to include buzzfeed_signin_entity
    end
  end

  private

  def deal
    @_deal ||= create :deal, creator: account_manager, budget: 20_000, company: company
  end

  def deal_mapper
    @_deal_mapper ||= Operative::Deals::Single.new(deal).to_xml(
      create: true,
      advertiser: false,
      agency: false,
      contact: false,
      enable_operative_extra_fields: false,
      buzzfeed: true
    )
  end

  def account_manager
    @_account_manager ||= create :user, email: 'test@email.com', user_type: ACCOUNT_MANAGER
  end

  def company
    @_company ||= create :company
  end

  def deal_custom_field
    @_deal_custom_field ||= create :deal_custom_field,
                                   deal: deal,
                                   text3: "new note",
                                   dropdown1: "Brazil",
                                   dropdown5: "BuzzFeed US"
  end

  def buzzfeed_billing_note
    "<customField>\n        <apiName>Billing_notes__c</apiName>\n        <value>#{deal_custom_field.text3}</value>\n      </customField>"
  end

  def buzzfeed_campaign_territory
    "<customField>\n        <apiName>Country_the_campaign_will_run_in__c</apiName>\n        <value>#{deal_custom_field.dropdown1}</value>\n      </customField>"
  end

  def buzzfeed_signin_entity
    "<customField>\n        <apiName>Buzzfeed_signing_entity</apiName>\n        <options>\n          <option>\n            <name>#{deal_custom_field.dropdown5}</name>\n          </option>\n        </options>\n      </customField>"
  end
end
