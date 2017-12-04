require 'rails_helper'

RSpec.describe Csv::Client, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:type) }
  it { should validate_presence_of(:company_id) }

  context 'custom validations' do
    context 'type validation' do
      it 'allows advertiser type' do
        csv_client(type: 'advertiser')
        expect(csv_client).to be_valid
      end

      it 'allows agency type' do
        csv_client(type: 'agency')
        expect(csv_client).to be_valid
      end

      it 'is case insensitive' do
        csv_client(type: 'aGeNcY')
        expect(csv_client).to be_valid
      end

      it 'rejects incorrect data in type' do
        csv_client(type: 'deal')
        expect(csv_client).not_to be_valid

        expect(csv_client.errors.full_messages).to include(
          'Type is invalid. Use "Agency" or "Advertiser" string'
        )
      end
    end

    context 'parent_client_exists' do
      it 'rejects clients which parents don\'t exist' do
        csv_client(parent_account: 'N/A')

        expect(csv_client).not_to be_valid

        expect(csv_client.errors.full_messages).to include (
          'Parent account N/A could not be found'
        )
      end

      it 'accepts existing parent client' do
        client

        csv_client(parent_account: client.name)

        expect(csv_client).to be_valid
      end

      it 'does case insensitive search' do
        client

        csv_client(parent_account: client.name.upcase)

        expect(csv_client).to be_valid
      end
    end

    context 'category validation' do
      it 'rejects nonexistent categories' do
        csv_client(type: 'advertiser', category: 'N/A')

        expect(csv_client).not_to be_valid

        expect(csv_client.errors.full_messages).to include "Category N/A could not be found"
      end

      it 'allows valid category' do
        csv_client(type: 'advertiser', category: category.name)

        expect(csv_client).to be_valid
      end

      it 'is valid without categories' do
        csv_client(type: 'advertiser', category: nil)

        expect(csv_client).to be_valid
      end

      it 'is valid with incorrect category if agency' do
        csv_client(type: 'Agency', category: 'N/A')

        expect(csv_client).to be_valid
      end
    end

    context 'subcategory validation' do
      it 'rejects nonexistent subcategories' do
        csv_client(type: 'advertiser', category: category.name, subcategory: 'N/A')

        expect(csv_client).not_to be_valid

        expect(csv_client.errors.full_messages).to include "Subcategory N/A could not be found"
      end

      it 'rejects subcategory from wrong category' do
        subcategory(option_id: other_category.id)

        csv_client(type: 'advertiser', category: category.name, subcategory: subcategory.name)

        expect(csv_client).not_to be_valid
      end

      it 'allows valid subcategory' do
        csv_client(type: 'advertiser', category: category.name, subcategory: subcategory.name)

        expect(csv_client).to be_valid
      end

      it 'is valid without subcategories' do
        csv_client(type: 'advertiser', category: nil, subcategory: nil)

        expect(csv_client).to be_valid
      end

      it 'is valid with incorrect subcategory if agency' do
        csv_client(type: 'Agency', category: 'N/A', subcategory: 'N/A')

        expect(csv_client).to be_valid
      end
    end

    context 'client_members_have_share' do
      it 'rejects client members without shares' do
        csv_client(teammembers: 'example@test.com;example2@test.com')

        expect(csv_client).not_to be_valid

        expect(csv_client.errors.full_messages).to include "Teammember example@test.com does not have a share value"
        expect(csv_client.errors.full_messages).to include "Teammember example2@test.com does not have a share value"
      end

      it 'allows client members with shares' do
        add_user('example@test.com')
        add_user('example2@test.com')

        csv_client(teammembers: 'example@test.com/50;example2@test.com/50')

        expect(csv_client).to be_valid
      end
    end

    context 'client_member_users_exist' do
      it 'rejects nonexistent client members' do
        csv_client(teammembers: 'example@test.com/50;example2@test.com/50')

        expect(csv_client).not_to be_valid

        expect(csv_client.errors.full_messages).to include "Teammember example@test.com could not be found in the users list"
        expect(csv_client.errors.full_messages).to include "Teammember example2@test.com could not be found in the users list"
      end

      it 'accepts existing users' do
        add_user('example@test.com')
        add_user('example2@test.com')

        csv_client(teammembers: 'example@test.com/50;example2@test.com/50')

        expect(csv_client).to be_valid
      end
    end

    context 'region exists' do
      it 'rejects nonexistent regions' do
        csv_client(region: 'N/A')

        expect(csv_client).not_to be_valid

        expect(csv_client.errors.full_messages).to include "Region N/A could not be found"
      end

      it 'accepts existing region' do
        csv_client(region: region.name)

        expect(csv_client).to be_valid
      end
    end

    context 'segment exists' do
      it 'rejects nonexistent segment' do
        csv_client(segment: 'N/A')

        expect(csv_client).not_to be_valid

        expect(csv_client.errors.full_messages).to include "Segment N/A could not be found"
      end

      it 'accepts existing segment' do
        csv_client(segment: segment.name)

        expect(csv_client).to be_valid
      end
    end

    context 'holding company exists' do
      it 'rejects nonexistent holding company' do
        csv_client(type: 'Agency', holding_company: 'N/A')

        expect(csv_client).not_to be_valid

        expect(csv_client.errors.full_messages).to include "Holding company N/A could not be found"
      end

      it 'accepts existing holding company' do
        csv_client(type: 'Agency', holding_company: holding_company.name)

        expect(csv_client).to be_valid
      end
    end

    context 'finding client' do
      it 'checks name match to just one client' do
        create_clients(2, name: 'Duplicate Name')

        csv_client(type: 'Advertiser', name: 'Duplicate Name')

        expect(csv_client).not_to be_valid

        expect(csv_client.errors.full_messages).to include "Account name Duplicate Name matched more than one account record"
      end
    end

    context 'not_self_parent' do
      it 'rejects record being set as a parent of self' do
        create_clients(1, name: 'Parent account')

        csv_client(name: 'Parent account', parent_account: 'Parent account')

        expect(csv_client).not_to be_valid

        expect(csv_client.errors.full_messages).to include "Account Parent account can't be set as a parent of itself"
      end
    end
  end

  context 'importing new client' do
    it 'creates a new client from csv' do
      parent_account = create_client

      expect do
        csv_client(
          parent_account: parent_account.name,
          category: category.name,
          subcategory: subcategory.name,
          region: region.name,
          segment: segment.name,
          teammembers: "#{new_user.email}/55",
        ).perform
      end.to change(::Client, :count).by(1)

      subject = Client.last
      address = subject.address

      expect(subject.name).to eq csv_client.name
      expect(subject.website).to eq csv_client.website
      expect(subject.parent_client.name).to eq csv_client.parent_account

      expect(subject.client_category.name).to eq csv_client.category
      expect(subject.client_subcategory.name).to eq csv_client.subcategory
      expect(subject.client_region.name).to eq csv_client.region
      expect(subject.client_segment.name).to eq csv_client.segment

      client_member = subject.client_members.find_by(user_id: new_user.id)
      expect(client_member).to be_present
      expect(client_member.share).to eq 55

      expect(address.street1).to eq csv_client.address
      expect(address.city).to eq csv_client.city
      expect(address.state).to eq csv_client.state
      expect(address.zip).to eq csv_client.zip
      expect(address.country).to eq csv_client.country
      expect(address.phone).to eq csv_client.phone.gsub(/[^0-9]/, '')
    end

    it 'imports custom fields' do
      setup_custom_fields(company)

      expect do
        csv_client_with_custom_fields.perform
      end.to change(AccountCf, :count).by(1)

      account_cf = AccountCf.last
      data = csv_client_with_custom_fields

      expect(account_cf.datetime1).to eq(data.unmatched_fields[:production_date])
      expect(account_cf.boolean1).to eq(data.unmatched_fields[:risky_click])
      expect(account_cf.number1.to_f).to eq(data.unmatched_fields[:target_views])
      expect(account_cf.text1).to eq(data.unmatched_fields[:deal_type])
    end
  end

  context 'updating existing client' do
    it 'imports new values from CSV' do
      existing_account = create_client
      parent_account = create_client

      expect do
        csv_client(
          name: existing_account.name,
          type: 'Advertiser',
          parent_account: parent_account.name,
          category: category(name: 'CPG').name,
          subcategory: subcategory.name,
          region: region(name: 'West').name,
          segment: segment(name: 'Small').name,
          teammembers: "#{new_user.email}/55",
          website: 'https://wonka.com/'
        ).perform
      end.not_to change(::Client, :count)

      subject = existing_account.reload
      address = existing_account.address

      expect(subject.name).to eq csv_client.name
      expect(subject.website).to eq csv_client.website
      expect(subject.parent_client.name).to eq csv_client.parent_account

      expect(subject.client_category.name).to eq csv_client.category
      expect(subject.client_subcategory.name).to eq csv_client.subcategory
      expect(subject.client_region.name).to eq csv_client.region
      expect(subject.client_segment.name).to eq csv_client.segment

      client_member = subject.client_members.find_by(user_id: new_user.id)
      expect(client_member).to be_present
      expect(client_member.share).to eq 55

      expect(address.street1).to eq csv_client.address
      expect(address.city).to eq csv_client.city
      expect(address.state).to eq csv_client.state
      expect(address.zip).to eq csv_client.zip
      expect(address.country).to eq csv_client.country
      expect(address.phone).to eq csv_client.phone.gsub(/[^0-9]/, '')

      expect(subject.values.map(&:option).map(&:name).sort).to eq(
        ["Advertiser", "CPG", "Small", "West"]
      )
    end
  end

  context 'removes existing teammembers' do
    it 'deletes teammembers if flag is true' do
      existing_account = create_client(created_by: user.id)

      csv_client(
        name: existing_account.name,
        replace_team: 'Y'
      ).perform

      subject = existing_account.reload
      expect(subject.client_members.count).to be 0
    end

    it 'replaces teammembers in place of old ones' do
      existing_account = create_client(created_by: user.id)

      csv_client(
        name: existing_account.name,
        teammembers: "#{new_user.email}/55",
        replace_team: 'Y'
      ).perform

      subject = existing_account.reload
      expect(subject.client_members.count).to be 1

      member = subject.client_members.first
      expect(member.share).to be 55
      expect(member.user.email).to eql new_user.email
    end
  end

  def create_clients(count, opts)
    defaults = {
      company_id: company.id
    }
    @_clients ||= create_list :client, count, defaults.merge(opts)
  end

  def create_client(opts={})
    defaults = {
      company_id: company.id
    }
    create :client, defaults.merge(opts)
  end

  def csv_client(opts={})
    defaults = {
      company_id: company.id,
      user_id: user.id,
      company_fields: company_fields
    }
    @_csv_client ||= build :csv_client, defaults.merge(opts)
  end

  def csv_client_with_custom_fields(opts={})
    defaults = {
      company_id: company.id,
      user_id: user.id,
      custom_field_names: company.account_cf_names,
      company_fields: company_fields
    }

    @_csv_client_with_custom_fields ||= build :csv_client_with_custom_fields,
      defaults.merge(opts)
  end

  def new_client_params
    {
      parent_account: create_client.name
    }
  end

  def client(opts={})
    defaults = {
      company_id: company.id
    }
    @_client ||= create :client, defaults.merge(opts)
  end

  def company
    @_company ||= create :company
  end

  def user(opts={})
    defaults = {
      company_id: company.id
    }
    @_user ||= create :user, defaults.merge(opts)
  end

  def new_user
    @_new_user ||= create :user, company_id: company.id
  end

  def category(opts={})
    defaults = {
      field: category_field,
      company_id: company.id
    }
    @_category ||= create :option, defaults.merge(opts)
  end

  def other_category
    @_other_category ||= create :option, field: category_field, company_id: company.id, name: 'Other'
  end

  def subcategory(opts={})
    defaults = {
      field: nil,
      option_id: category.id,
      company_id: company.id
    }
    @_subcategory ||= create :option, defaults.merge(opts)
  end

  def region(opts={})
    defaults = {
      field: region_field,
      company_id: company.id
    }
    @_region ||= create :option, defaults.merge(opts)
  end

  def segment(opts={})
    defaults = {
      field: segment_field,
      company_id: company.id
    }
    @_segment ||= create :option, defaults.merge(opts)
  end

  def category_field
    @_category_field ||= company.fields.find_by_name 'Category'
  end

  def region_field
    @_region_field ||= company.fields.find_by_name 'Region'
  end

  def segment_field
    @_segment_field ||= company.fields.find_by_name 'Segment'
  end

  def add_user(email)
    create :user, email: email, company_id: company.id
  end

  def holding_company
    @_holding_company ||= create :holding_company
  end

  def setup_custom_fields(company)
    create :account_cf_name, field_type: 'datetime', field_label: 'Production Date', company: company
    create :account_cf_name, field_type: 'boolean',  field_label: 'Risky Click?', company: company
    create :account_cf_name, field_type: 'number',   field_label: 'Target Views', company: company
    create :account_cf_name, field_type: 'text',     field_label: 'Deal Type', company: company
  end

  def company_fields
    company.account_fields_data
  end
end
