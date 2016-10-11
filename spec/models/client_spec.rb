require 'rails_helper'

RSpec.describe Client, type: :model do
  context 'validation' do
    it { should validate_presence_of(:name) }
  end

  context 'association' do
    it { should have_many(:client_members) }
    it { should have_many(:users).through(:client_members) }
  end

  context 'to_csv' do
    let!(:clients) { create_list :client, 2, name: 'Bob' }

    it 'returns the id and name of the clients' do
      header = "Client ID,Name,Parent,Category,Subcategory\n"
      body = "#{clients[0].id},Bob,,,\n#{clients[1].id},Bob,,,\n"
      csv = Client.to_csv
      expect(csv).to eq(header + body)
    end
  end
end
