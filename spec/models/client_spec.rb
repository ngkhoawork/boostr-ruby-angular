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
      let(:category_field) { user.company.fields.where(name: 'Category').first }
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
    let!(:user) { create :user, company: company }
    let!(:user2) { create :user, company: company }
    let!(:user3) { create :user, company: company }
    let!(:category_field) { user.company.fields.where(name: 'Category').first }
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

  describe '#import' do
    let!(:user) { create :user, company: company }
    let!(:client) { create :client, company: company }
    let!(:existing_client) { create :client, company: company }
    let!(:existing_client2) { create :client, company: company }
    let!(:category_field) { user.company.fields.where(name: 'Category').first }
    let!(:category) { create :option, field: category_field, company: user.company }
    let!(:subcategory) { create :option, option: category, company: user.company }

    let(:new_client_csv) { build :client_csv_data, type: 'Advertiser', company_id: company.id }
    let(:existing_client_csv) { build :client_csv_data, type: 'Advertiser', name: existing_client.name, company_id: company.id }
    let(:existing_client_csv_id) { build :client_csv_data, type: 'Advertiser', id: existing_client2.id, company_id: company.id }

    it 'creates a new client from csv' do
      expect do
        Client.import(generate_csv(new_client_csv), user.id, '/tmp/clients.csv')
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
        Client.import(generate_csv(existing_client_csv), user.id, '/tmp/clients.csv')
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
        Client.import(generate_csv(existing_client_csv_id), user.id, '/tmp/clients.csv')
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

    context 'csv import log' do
      it 'creates csv import log' do
        expect do
          Client.import(generate_csv(new_client_csv), user.id, '/tmp/clients.csv')
        end.to change(CsvImportLog, :count).by(1)
      end

      it 'saves amount of processed rows for new clients' do
        Client.import(generate_csv(new_client_csv), user.id, '/tmp/clients.csv')

        import_log = CsvImportLog.last

        expect(import_log.rows_processed).to be 1
        expect(import_log.rows_imported).to be 1
        expect(import_log.file_source).to eq 'clients.csv'
      end

      it 'saves amount of processed rows when updating existing clients' do
        Client.import(generate_csv(existing_client_csv_id), user.id, '/tmp/clients.csv')

        import_log = CsvImportLog.last

        expect(import_log.rows_processed).to be 1
        expect(import_log.rows_imported).to be 1
      end

      it 'counts failed rows' do
        no_name = build :client_csv_data, name: nil, company_id: company.id
        Client.import(generate_csv(no_name), user.id, '/tmp/clients.csv')

        import_log = CsvImportLog.last

        expect(import_log.rows_processed).to be 1
        expect(import_log.rows_failed).to be 1
      end
    end

    context 'invalid data' do
      let!(:duplicate1) { create :client, company: company }
      let!(:duplicate2) { create :client, name: duplicate1.name, company: company }
      let(:no_name) { build :client_csv_data, name: nil, company_id: company.id }
      let(:no_type) { build :client_csv_data, type: nil, company_id: company.id }
      let(:invalid_parent) { build :client_csv_data, parent: 'N/A', company_id: company.id }
      let(:invalid_category) { build :client_csv_data, category: 'N/A', type: 'Advertiser', company_id: company.id }
      let(:invalid_subcategory) { build :client_csv_data, subcategory: 'N/A', type: 'Advertiser', company_id: company.id }
      let(:invalid_share) { build :client_csv_data, teammembers: 'first;second', company_id: company.id }
      let(:invalid_team_member) { build :client_csv_data, teammembers: 'NA/100', company_id: company.id }
      let(:own_parent) { build :client_csv_data, name: client.name, parent: client.name , company_id: company.id}
      let(:ambigous_match) { build :client_csv_data, name: duplicate1.name, company_id: company.id }
      let(:import_log) { CsvImportLog.last }
      let(:missing_holding_company) { build :client_csv_data, type: 'agency', holding_company: 'AbInBev', company_id: company.id }
      let(:missing_region) { build :client_csv_data, region: 'NaN', company_id: company.id }
      let(:missing_segment) { build :client_csv_data, segment: 'NaN', company_id: company.id }

      it 'requires name to be present' do
        Client.import(generate_csv(no_name), user.id, '/tmp/clients.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq [{ "row" => 1, "message" => ['Name is empty'] }]
      end

      it 'requires type to be present' do
        Client.import(generate_csv(no_type), user.id, '/tmp/clients.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq [{ "row" => 1, "message" => ['Type is empty'] }]
      end

      it 'validates account type' do
        no_type[:type] = 'test'

        Client.import(generate_csv(no_type), user.id, '/tmp/clients.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ['Type is invalid. Use "Agency" or "Advertiser" string'] }]
        )
      end

      it 'requires parent account to exist' do
        Client.import(generate_csv(invalid_parent), user.id, '/tmp/clients.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Parent account #{invalid_parent[:parent]} could not be found"] }]
        )
      end

      it 'requires category to exist' do
        Client.import(generate_csv(invalid_category), user.id, '/tmp/clients.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Category #{invalid_category[:category]} could not be found"] }]
        )
      end

      it 'requires subcategory to exist' do
        Client.import(generate_csv(invalid_subcategory), user.id, '/tmp/clients.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Subcategory #{invalid_subcategory[:subcategory]} could not be found"] }]
        )
      end

      it 'validates equality of team member and shares length' do
        Client.import(generate_csv(invalid_share), user.id, '/tmp/clients.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Account team member first does not have share"] }]
        )
      end

      it 'requires account search by name to match no more than 1 account' do
        Client.import(generate_csv(ambigous_match), user.id, '/tmp/clients.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Account name #{ambigous_match[:name]} matched more than one account record"] }]
        )
      end

      it 'validates team member presence' do
        Client.import(generate_csv(invalid_team_member), user.id, '/tmp/clients.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Account team member #{invalid_team_member[:teammembers].split('/')[0]} could not be found in the users list"] }]
        )
      end

      it 'rejects accounts set to be parents of themselves' do
        Client.import(generate_csv(own_parent), user.id, '/tmp/clients.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Accounts can't be parents of themselves"] }]
        )
      end

      it 'validates presence of region' do
        Client.import(generate_csv(missing_region), user.id, '/tmp/clients.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Region NaN could not be found"] }]
        )
      end

      it 'validates presence of segment' do
        Client.import(generate_csv(missing_segment), user.id, '/tmp/clients.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Segment NaN could not be found"] }]
        )
      end

      it 'validates presence of holding company' do
        Client.import(generate_csv(missing_holding_company), user.id, '/tmp/clients.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Holding company AbInBev could not be found"] }]
        )
      end
    end

    context 'client custom fields' do
      xit 'imports account custom field' do
        setup_custom_fields(company)
        new_client_csv = build :client_csv_data_custom_fields,
                type: 'Advertiser',
                custom_field_names: company.account_cf_names,
                company_id: company.id

        expect do
          Client.import(generate_csv(new_client_csv), user.id, '/tmp/clients.csv')
        end.to change(AccountCf, :count).by(1)

        account_cf = AccountCf.last

        expect(account_cf.datetime1).to eq(new_client_csv[:production_date])
        expect(account_cf.boolean1).to eq(new_client_csv[:risky_click])
        expect(account_cf.number1.to_f).to eq(new_client_csv[:target_views])
        expect(account_cf.text1).to eq(new_client_csv[:deal_type])
      end
    end
  end

  describe '#connection_entry_ids' do
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

  def company
    @_company ||= create :company
  end
end
