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

  describe '#import' do
    let!(:user) { create :user }
    let!(:client) { create :client }
    let!(:existing_client) { create :client }
    let!(:existing_client2) { create :client }
    let!(:company) { user.company }
    let!(:category_field) { user.company.fields.where(name: 'Category').first }
    let!(:category) { create :option, field: category_field, company: user.company }
    let!(:subcategory) { create :option, option: category, company: user.company }

    let(:new_client_csv) { build :client_csv_data, type: 'Advertiser' }
    let(:existing_client_csv) { build :client_csv_data, type: 'Advertiser', name: existing_client.name }
    let(:existing_client_csv_id) { build :client_csv_data, type: 'Advertiser', id: existing_client2.id }

    it 'creates a new client from csv' do
      expect do
        expect(Client.import(generate_csv(new_client_csv), user)).to eq([])
      end.to change(Client, :count).by(1)

      new_client = Client.last
      expect(new_client.name).to eq(new_client_csv[:name])
      expect(new_client.parent_client.name).to eq(new_client_csv[:parent])
      expect(new_client.client_category.name).to eq(new_client_csv[:category])
      expect(new_client.client_subcategory.name).to eq(new_client_csv[:subcategory])
      expect(new_client.address.street1).to eq(new_client_csv[:address])
      expect(new_client.address.city).to eq(new_client_csv[:city])
      expect(new_client.address.state).to eq(new_client_csv[:state])
      expect(new_client.address.zip).to eq(new_client_csv[:zip])
      expect(new_client.address.phone).to eq(new_client_csv[:phone].gsub(/[^0-9]/, ''))
      expect(new_client.website).to eq(new_client_csv[:website])
      expect(new_client.client_members.first.user.email).to eq(new_client_csv[:teammembers])
      expect(new_client.client_members.first.share).to eq(new_client_csv[:shares].to_i)
    end

    it 'updates an existing client by email match' do
      expect do
        expect(Client.import(generate_csv(existing_client_csv), user)).to eq([])
      end.not_to change(Client, :count)
      existing_client.reload

      expect(existing_client.name).to eq(existing_client_csv[:name])
      expect(existing_client.parent_client.name).to eq(existing_client_csv[:parent])
      expect(existing_client.client_category.name).to eq(existing_client_csv[:category])
      expect(existing_client.client_subcategory.name).to eq(existing_client_csv[:subcategory])
      expect(existing_client.address.street1).to eq(existing_client_csv[:address])
      expect(existing_client.address.city).to eq(existing_client_csv[:city])
      expect(existing_client.address.state).to eq(existing_client_csv[:state])
      expect(existing_client.address.zip).to eq(existing_client_csv[:zip])
      expect(existing_client.address.phone).to eq(existing_client_csv[:phone].gsub(/[^0-9]/, ''))
      expect(existing_client.website).to eq(existing_client_csv[:website])
      expect(existing_client.client_members.first.user.email).to eq(existing_client_csv[:teammembers])
      expect(existing_client.client_members.first.share).to eq(existing_client_csv[:shares].to_i)
    end

    it 'updates an existing client by ID match' do
      expect do
        expect(Client.import(generate_csv(existing_client_csv_id), user)).to eq([])
      end.not_to change(Client, :count)
      existing_client2.reload

      expect(existing_client2.name).to eq(existing_client_csv_id[:name])
      expect(existing_client2.parent_client.name).to eq(existing_client_csv_id[:parent])
      expect(existing_client2.client_category.name).to eq(existing_client_csv_id[:category])
      expect(existing_client2.client_subcategory.name).to eq(existing_client_csv_id[:subcategory])
      expect(existing_client2.address.street1).to eq(existing_client_csv_id[:address])
      expect(existing_client2.address.city).to eq(existing_client_csv_id[:city])
      expect(existing_client2.address.state).to eq(existing_client_csv_id[:state])
      expect(existing_client2.address.zip).to eq(existing_client_csv_id[:zip])
      expect(existing_client2.address.phone).to eq(existing_client_csv_id[:phone].gsub(/[^0-9]/, ''))
      expect(existing_client2.website).to eq(existing_client_csv_id[:website])
      expect(existing_client2.client_members.first.user.email).to eq(existing_client_csv_id[:teammembers])
      expect(existing_client2.client_members.first.share).to eq(existing_client_csv_id[:shares].to_i)
    end

    context 'invalid data' do
      let!(:duplicate1) { create :client }
      let!(:duplicate2) { create :client, name: duplicate1.name }
      let(:no_name) { build :client_csv_data, name: nil }
      let(:no_type) { build :client_csv_data, type: nil }
      let(:invalid_parent) { build :client_csv_data, parent: 'N/A' }
      let(:invalid_category) { build :client_csv_data, category: 'N/A', type: 'Advertiser' }
      let(:invalid_subcategory) { build :client_csv_data, subcategory: 'N/A', type: 'Advertiser' }
      let(:invalid_team_share_length) { build :client_csv_data, teammembers: 'first;second', shares: '100' }
      let(:invalid_team_member) { build :client_csv_data, teammembers: 'N/A' }
      let(:own_parent) { build :client_csv_data, name: client.name }
      let(:ambigous_match) { build :client_csv_data, name: duplicate1.name }

      it 'requires name to be present' do
        expect(
          Client.import(generate_csv(no_name), user)
        ).to eq([{:row=>1, :message=>['Name is empty']}])
      end

      it 'requires type to be present' do
        expect(
          Client.import(generate_csv(no_type), user)
        ).to eq([{:row=>1, :message=>['Type is empty']}])
      end

      it 'validates client type' do
        no_type[:type] = 'test'
        expect(
          Client.import(generate_csv(no_type), user)
        ).to eq([{:row=>1, :message=>['Type is invalid. Use "Agency" or "Advertiser" string']}])
      end

      it 'requires parent client to exist' do
        expect(
          Client.import(generate_csv(invalid_parent), user)
        ).to eq([{:row=>1, :message=>["Parent client #{invalid_parent[:parent]} could not be found"]}])
      end

      it 'requires category to exist' do
        expect(
          Client.import(generate_csv(invalid_category), user)
        ).to eq([{:row=>1, :message=>["Category #{invalid_category[:category]} could not be found"]}])
      end

      it 'requires subcategory to exist' do
        expect(
          Client.import(generate_csv(invalid_subcategory), user)
        ).to eq([{:row=>1, :message=>["Subcategory #{invalid_subcategory[:subcategory]} could not be found"]}])
      end

      it 'validates equality of team member and shares length' do
        expect(
          Client.import(generate_csv(invalid_team_share_length), user)
        ).to eq([{:row=>1, :message=>["Client team members count does not match shares count"]}])
      end

      it 'requires client search by name to match no more than 1 client' do
        expect(
          Client.import(generate_csv(ambigous_match), user)
        ).to eq([{:row=>1, :message=>["Client name #{ambigous_match[:name]} matched more than one client record"]}])
      end

      it 'validates team member presence' do
        expect(
          Client.import(generate_csv(invalid_team_member), user)
        ).to eq([{:row=>1, :message=>["Client team member #{invalid_team_member[:teammembers]} could not be found in the users list"]}])
      end

      it 'rejects clients set to be parents of themselves' do
        expect(
          Client.import(generate_csv(own_parent), user)
        ).to eq([{:row=>1, :message=>["Clients can't be parents of themselves"]}])
      end
    end
  end

  def generate_csv(data)
    CSV.generate do |csv|
      csv << data.keys
      csv << data.values
    end
  end
end
