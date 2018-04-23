require 'rails_helper'

RSpec.describe Client, type: :model do
  context 'validation' do
    it { should validate_presence_of(:name) }
  end

  context 'association' do
    it { should have_many(:client_members) }
    it { should have_many(:users).through(:client_members) }
  end

  describe 'scopes' do
    describe '.search_by_name' do
      let(:company) { create :company }
      let(:user) { create :user, company: company }
      let(:category_field) do
        company.fields.find_or_initialize_by(subject_type: 'Client', name: 'Category', value_type: 'Option', locked: true)
      end
      let(:category) { create :option, field: category_field, company: user.company }
      let!(:client) do
        create :client,
          name: 'Amazon', client_category: category, client_type_id: advertiser_type_id(company), company: company
      end

      subject { Client.search_by_name(search_name) }

      context 'with exact param match' do
        let(:search_name) { client.name }

        it { expect(subject).to include client }
      end

      context 'with partial param match' do
        let(:search_name) { 'The Amazon Corp.' }

        it { expect(subject).to include client }
      end

      context 'with fuzzy param match' do
        let(:search_name) { 'Amozon' }

        it { expect(subject).to include client }
      end
    end
  end

  context 'to_csv' do
    let(:company) { create :company }
    let!(:user) { create :user, company: company }
    let!(:user2) { create :user, company: company }
    let!(:user3) { create :user, company: company }
    let(:category_field) do
      company.fields.find_or_initialize_by(subject_type: 'Client', name: 'Category', value_type: 'Option', locked: true)
    end
    let!(:category) { create :option, field: category_field, company: user.company }
    let!(:subcategory) { create :option, option: category, company: user.company }
    let!(:client) { create :client, client_category: category, client_subcategory: subcategory, client_type_id: advertiser_type_id(company), company: company }
    let!(:client_member1) { create :client_member, client: client, user: user }
    let!(:client_member2) { create :client_member, client: client, user: user2 }
    let!(:client_member3) { create :client_member, client: client, user: user3 }
    let(:headers) { attributes_for :client_csv_data }
    let(:client_ordered_data) {
      build :client_csv_data,
      id: client.id,
      name: client.name,
      type: 'Advertiser',
      parent: client.parent_client.name,
      category: client.client_category.name,
      subcategory: client.client_subcategory.name,
      address: client.address.street1,
      city: client.address.city,
      state: client.address.state,
      zip: client.address.zip,
      phone: client.address.phone,
      website: client.website,
      replace_team: '',
      teammembers: [client.users.map(&:email), client.client_members.map(&:share).map(&:to_s)].transpose.map{|el|el.join('/')}.join(';')
    }

    it 'returns correct data for account' do
      data = CSV.parse(Client.where(id: client.id).to_csv(client.company))

      expect(data[1]).to include(client_ordered_data[:id].to_s)
      expect(data[1]).to include(client_ordered_data[:name])
      expect(data[1]).to include(client_ordered_data[:type])
      expect(data[1]).to include(client_ordered_data[:parent])
      expect(data[1]).to include(client_ordered_data[:category])
      expect(data[1]).to include(client_ordered_data[:subcategory])
      expect(data[1]).to include(client_ordered_data[:address])
      expect(data[1]).to include(client_ordered_data[:city])
      expect(data[1]).to include(client_ordered_data[:state])
      expect(data[1]).to include(client_ordered_data[:zip])
      expect(data[1]).to include(client_ordered_data[:phone])
      expect(data[1]).to include(client_ordered_data[:website])
      expect(data[1]).to include(client_ordered_data[:teammembers])
    end

    it 'creates CSV with broken parent account link' do
      client.parent_client.destroy
      data = CSV.parse(Client.where(id: client.id).to_csv(client.company))
      client_ordered_data[:parent] = nil

      expect(data[1]).to include(client_ordered_data[:id].to_s)
      expect(data[1]).to include(client_ordered_data[:name])
      expect(data[1]).to include(client_ordered_data[:type])
      expect(data[1]).to include(client_ordered_data[:category])
      expect(data[1]).to include(client_ordered_data[:subcategory])
      expect(data[1]).to include(client_ordered_data[:address])
      expect(data[1]).to include(client_ordered_data[:city])
      expect(data[1]).to include(client_ordered_data[:state])
      expect(data[1]).to include(client_ordered_data[:zip])
      expect(data[1]).to include(client_ordered_data[:phone])
      expect(data[1]).to include(client_ordered_data[:website])
      expect(data[1]).to include(client_ordered_data[:teammembers])
    end

    it 'creates CSV with broken category and subcategory link' do
      client.client_category.destroy
      client.client_subcategory.destroy
      data = CSV.parse(Client.where(id: client.id).to_csv(client.company))
      client_ordered_data[:category] = nil
      client_ordered_data[:subcategory] = nil

      expect(data[1]).to include(client_ordered_data[:id].to_s)
      expect(data[1]).to include(client_ordered_data[:name])
      expect(data[1]).to include(client_ordered_data[:type])
      expect(data[1]).to include(client_ordered_data[:parent])
      expect(data[1]).to include(client_ordered_data[:address])
      expect(data[1]).to include(client_ordered_data[:city])
      expect(data[1]).to include(client_ordered_data[:state])
      expect(data[1]).to include(client_ordered_data[:zip])
      expect(data[1]).to include(client_ordered_data[:phone])
      expect(data[1]).to include(client_ordered_data[:website])
      expect(data[1]).to include(client_ordered_data[:teammembers])
    end
  end

  context 'base field validations' do
    let(:company) { create :company_with_defaults }
    let(:advertiser) { create :bare_client, client_type_id: advertiser_type_id(company), company: company }
    let(:agency) { create :bare_client, client_type_id: agency_type_id(company), company: company }

    it 'is valid when base validations are off' do
      base_validations(advertiser).map { |v| v.criterion.update(value: false) }
      expect(advertiser).to be_valid
    end

    it 'is not valid when base validations are on' do
      base_validations(agency).map { |v| v.criterion.update(value: true) }
      expect(agency).not_to be_valid
    end

    it 'returns validation errors for advertiser' do
      base_validations(advertiser).map { |v| v.criterion.update(value: true) }

      expect(advertiser).not_to be_valid
      expect(advertiser.errors.full_messages).to include 'Client category can\'t be blank'
      expect(advertiser.errors.full_messages).to include 'Client subcategory can\'t be blank'
      expect(advertiser.errors.full_messages).to include 'Client region can\'t be blank'
      expect(advertiser.errors.full_messages).to include 'Client segment can\'t be blank'
      expect(advertiser.errors.full_messages).to include 'Phone can\'t be blank'
      expect(advertiser.errors.full_messages).to include 'Website can\'t be blank'
    end

    it 'returns validation errors for agency' do
      base_validations(agency).map { |v| v.criterion.update(value: true) }

      expect(agency).not_to be_valid
      expect(agency.errors.full_messages).to include 'Client region can\'t be blank'
      expect(agency.errors.full_messages).to include 'Client segment can\'t be blank'
      expect(agency.errors.full_messages).to include 'Phone can\'t be blank'
      expect(agency.errors.full_messages).to include 'Website can\'t be blank'
    end
  end

  describe '#connection_entry_ids' do
    let(:company) { create :company }
    subject { client.connection_entry_ids }

    context 'when client is advertiser' do
      let(:client) { create :bare_client, client_type_id: advertiser_type_id(company), company: company }
      let(:related_agency) { create :bare_client, client_type_id: agency_type_id(company), company: company }

      before { client.agencies << related_agency }

      it { expect(subject).to eq [related_agency.id] }
    end

    context 'when client is agency' do
      let(:client) { create :bare_client, client_type_id: agency_type_id(company), company: company }
      let(:related_advertiser) { create :bare_client, client_type_id: advertiser_type_id(company), company: company }

      before(:each) { client.advertisers << related_advertiser }

      it { expect(subject).to eq [related_advertiser.id] }
    end
  end

  def generate_csv(data)
    CSV.generate do |csv|
      csv << data.keys
      csv << data.values
    end
  end

  private

  def setup_custom_fields(company)
    create :account_cf_name, field_type: 'datetime', field_label: 'Production Date', company: company
    create :account_cf_name, field_type: 'boolean',  field_label: 'Risky Click?', company: company
    create :account_cf_name, field_type: 'number',   field_label: 'Target Views', company: company
    create :account_cf_name, field_type: 'text',     field_label: 'Deal Type', company: company
  end

  def base_validations(subject)
    subject.base_field_validations
  end
end
