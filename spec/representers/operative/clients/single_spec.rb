require 'rails_helper'

describe Operative::Clients::Single, operative: true do
  let(:company) { create :company }
  let(:parent_client) { create :client }
  let(:client) { create :client, client_type_id: advertiser_type_id(company), name: 'Some client', parent_client: parent_client }
  let(:client_mapper) { described_class.new(client).to_hash }

  it 'has proper mapped value' do
    expect(client_mapper['externalID']).to eq external_id
    expect(client_mapper['name']).to eq client.name
    expect(client_mapper['city']).to eq client.city
    expect(client_mapper['state']).to eq client.state
    expect(client_mapper['zip']).to eq client.zip
    expect(client_mapper['phone']).to eq client.phone
    expect(client_mapper['country']).to eq client.country
    expect(client_mapper['addressline1']).to eq client.street1
    expect(client_mapper['addressline2']).to eq client.street2
    expect(client_mapper['industry']).to eq client.category_name
    expect(client_mapper['accountType']).to eq 'advertiser'
    expect(client_mapper['parentAccount']).to eq parent_client.name
  end

  private

  def external_id
    "boostr_#{client.id}_#{client.company.name}_account"
  end
end
