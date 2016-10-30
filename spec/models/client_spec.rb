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
    let!(:user) { create :user }
    let!(:user2) { create :user }
    let!(:user3) { create :user }
    let!(:company) { user.company }
    let!(:category_field) { user.company.fields.where(name: 'Category').first }
    let!(:category) { create :option, field: category_field, company: user.company }
    let!(:subcategory) { create :option, option: category, company: user.company }
    let!(:client) { create :client, client_category: category, client_subcategory: subcategory }
    let!(:client_member1) { create :client_member, client: client, user: user }
    let!(:client_member2) { create :client_member, client: client, user: user2 }
    let!(:client_member3) { create :client_member, client: client, user: user3 }
    let(:headers) { attributes_for :client_csv_data }
    let(:client_ordered_data) {
      build :client_csv_data,
      id: client.id,
      name: client.name,
      type: client.client_type_id,
      parent: '',
      category: client.client_category.name,
      subcategory: client.client_subcategory.name,
      address: client.address.street1,
      city: client.address.city,
      state: client.address.state,
      zip: client.address.zip,
      phone: client.address.phone,
      website: client.website,
      replace_team: '',
      teammembers: [client.users.order(:id).map(&:email), client.client_members.order(:user_id).map(&:share).map(&:to_s)].transpose.map{|el|el.join('/')}.join(';')
    }

    it 'returns correct headers' do
      data = CSV.parse(Client.to_csv)
      data_headers = headers.keys.map(&:capitalize).map(&:to_s)
      expect(data[0]).to eq(data_headers)
    end

    it 'returns correct data for client' do
      data = CSV.parse(Client.to_csv)
      client_data = client_ordered_data.values.map(&:to_s).map { |el| el == '' ? nil : el }
      expect(data[1]).to eq(client_data)
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
      expect(new_client.client_members.first.user.email).to eq(new_client_csv[:teammembers].split('/')[0])
      expect(new_client.client_members.first.share).to eq(new_client_csv[:teammembers].split('/')[1].to_i)
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
      expect(existing_client.client_members.first.user.email).to eq(existing_client_csv[:teammembers].split('/')[0])
      expect(existing_client.client_members.first.share).to eq(existing_client_csv[:teammembers].split('/')[1].to_i)
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
      expect(existing_client2.client_members.first.user.email).to eq(existing_client_csv_id[:teammembers].split('/')[0])
      expect(existing_client2.client_members.first.share).to eq(existing_client_csv_id[:teammembers].split('/')[1].to_i)
    end

    context 'invalid data' do
      let!(:duplicate1) { create :client }
      let!(:duplicate2) { create :client, name: duplicate1.name }
      let(:no_name) { build :client_csv_data, name: nil }
      let(:no_type) { build :client_csv_data, type: nil }
      let(:invalid_parent) { build :client_csv_data, parent: 'N/A' }
      let(:invalid_category) { build :client_csv_data, category: 'N/A', type: 'Advertiser' }
      let(:invalid_subcategory) { build :client_csv_data, subcategory: 'N/A', type: 'Advertiser' }
      let(:invalid_share) { build :client_csv_data, teammembers: 'first;second' }
      let(:invalid_team_member) { build :client_csv_data, teammembers: 'NA/100' }
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
          Client.import(generate_csv(invalid_share), user)
        ).to eq([{:row=>1, :message=>["Client team member first does not have share"]}])
      end

      it 'requires client search by name to match no more than 1 client' do
        expect(
          Client.import(generate_csv(ambigous_match), user)
        ).to eq([{:row=>1, :message=>["Client name #{ambigous_match[:name]} matched more than one client record"]}])
      end

      it 'validates team member presence' do
        expect(
          Client.import(generate_csv(invalid_team_member), user)
        ).to eq([{:row=>1, :message=>["Client team member #{invalid_team_member[:teammembers].split('/')[0]} could not be found in the users list"]}])
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
