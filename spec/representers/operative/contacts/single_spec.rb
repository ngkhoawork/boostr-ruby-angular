require 'rails_helper'

describe Operative::Contacts::Single do
  it 'has proper mapped value' do
    expect(contact_mapper['externalID']).to eq contact.id.to_s
    expect(contact_mapper['firstname']).to eq 'Joe'
    expect(contact_mapper['lastname']).to eq 'Doe'
    expect(contact_mapper['email']).to eq contact.address.email
    expect(contact_mapper['mobile']).to eq contact.address.mobile
    expect(contact_mapper['phone']).to eq contact.address.phone
    expect(contact_mapper['addressline1']).to eq contact.address.street1
    expect(contact_mapper['addressline2']).to eq contact.address.street2
    expect(contact_mapper['city']).to eq contact.address.city
    expect(contact_mapper['state']).to eq contact.address.state
    expect(contact_mapper['zip']).to eq contact.address.zip
  end

  private

  def contact
    @_contact ||= create :contact, name: 'Joe Doe'
  end

  def contact_mapper
    @_contact_mapper ||= described_class.new(contact).to_hash
  end
end
