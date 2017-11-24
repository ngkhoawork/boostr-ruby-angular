require 'rails_helper'

RSpec.describe ClientCsv, type: :model do
  CLASS_VARIABLES_TO_CLEAN = [
    :@@type_field, :@@category_field, :@@region_field, :@@segment_field
  ]

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:type) }
  it { should validate_presence_of(:company_id) }

  after do
    reset_class_variables(ClientCsv, CLASS_VARIABLES_TO_CLEAN)
  end

  context 'custom validations' do
    context 'type validation' do
      it 'allows advertiser type' do
        client_csv(type: 'advertiser')
        expect(client_csv).to be_valid
      end

      it 'allows agency type' do
        client_csv(type: 'agency')
        expect(client_csv).to be_valid
      end

      it 'is case insensitive' do
        client_csv(type: 'aGeNcY')
        expect(client_csv).to be_valid
      end

      it 'rejects incorrect data in type' do
        client_csv(type: 'deal')
        expect(client_csv).not_to be_valid

        expect(client_csv.errors.full_messages).to include(
          'Type is invalid. Use "Agency" or "Advertiser" string'
        )
      end
    end

    context 'parent_client_exists' do
      it 'rejects clients which parents don\'t exist' do
        client_csv(parent_account: 'N/A')

        expect(client_csv).not_to be_valid

        expect(client_csv.errors.full_messages).to include (
          'Parent account N/A could not be found'
        )
      end

      it 'accepts existing parent client' do
        client

        client_csv(parent_account: client.name)

        expect(client_csv).to be_valid
      end

      it 'does case insensitive search' do
        client

        client_csv(parent_account: client.name.upcase)

        expect(client_csv).to be_valid
      end
    end

    context 'category validation' do
      it 'rejects nonexistent categories' do
        client_csv(type: 'advertiser', category: 'N/A')

        expect(client_csv).not_to be_valid

        expect(client_csv.errors.full_messages).to include "Category N/A could not be found"
      end

      it 'allows valid category' do
        client_csv(type: 'advertiser', category: category.name)

        expect(client_csv).to be_valid
      end

      it 'is valid without categories' do
        client_csv(type: 'advertiser', category: nil)

        expect(client_csv).to be_valid
      end

      it 'is valid with incorrect category if agency' do
        client_csv(type: 'Agency', category: 'N/A')

        expect(client_csv).to be_valid
      end
    end

    context 'subcategory validation' do
      it 'rejects nonexistent subcategories' do
        client_csv(type: 'advertiser', category: category.name, subcategory: 'N/A')

        expect(client_csv).not_to be_valid

        expect(client_csv.errors.full_messages).to include "Subcategory N/A could not be found"
      end

      it 'rejects subcategory from wrong category' do
        subcategory(option_id: other_category.id)

        client_csv(type: 'advertiser', category: category.name, subcategory: subcategory.name)

        expect(client_csv).not_to be_valid
      end

      it 'allows valid subcategory' do
        client_csv(type: 'advertiser', category: category.name, subcategory: subcategory.name)

        expect(client_csv).to be_valid
      end

      it 'is valid without subcategories' do
        client_csv(type: 'advertiser', category: nil, subcategory: nil)

        expect(client_csv).to be_valid
      end

      it 'is valid with incorrect subcategory if agency' do
        client_csv(type: 'Agency', category: 'N/A', subcategory: 'N/A')

        expect(client_csv).to be_valid
      end
    end

    context 'client_members_have_share' do
      it 'rejects client members without shares' do
        client_csv(teammembers: 'example@test.com;example2@test.com')

        expect(client_csv).not_to be_valid

        expect(client_csv.errors.full_messages).to include "Teammember example@test.com does not have a share value"
        expect(client_csv.errors.full_messages).to include "Teammember example2@test.com does not have a share value"
      end

      it 'allows client members with shares' do
        add_user('example@test.com')
        add_user('example2@test.com')

        client_csv(teammembers: 'example@test.com/50;example2@test.com/50')

        expect(client_csv).to be_valid
      end
    end

    context 'client_member_users_exist' do
      it 'rejects nonexistent client members' do
        client_csv(teammembers: 'example@test.com/50;example2@test.com/50')

        expect(client_csv).not_to be_valid

        expect(client_csv.errors.full_messages).to include "Teammember example@test.com could not be found in the users list"
        expect(client_csv.errors.full_messages).to include "Teammember example2@test.com could not be found in the users list"
      end

      it 'accepts existing users' do
        add_user('example@test.com')
        add_user('example2@test.com')

        client_csv(teammembers: 'example@test.com/50;example2@test.com/50')

        expect(client_csv).to be_valid
      end
    end

    context 'region exists' do
      it 'rejects nonexistent regions' do
        client_csv(region: 'N/A')

        expect(client_csv).not_to be_valid

        expect(client_csv.errors.full_messages).to include "Region N/A could not be found"
      end

      it 'accepts existing region' do
        client_csv(region: region.name)

        expect(client_csv).to be_valid
      end
    end

    context 'segment exists' do
      it 'rejects nonexistent segment' do
        client_csv(segment: 'N/A')

        expect(client_csv).not_to be_valid

        expect(client_csv.errors.full_messages).to include "Segment N/A could not be found"
      end

      it 'accepts existing segment' do
        client_csv(segment: segment.name)

        expect(client_csv).to be_valid
      end
    end

    context 'holding company exists' do
      it 'rejects nonexistent holding company' do
        client_csv(type: 'Agency', holding_company: 'N/A')

        expect(client_csv).not_to be_valid

        expect(client_csv.errors.full_messages).to include "Holding company N/A could not be found"
      end

      it 'accepts existing holding company' do
        client_csv(type: 'Agency', holding_company: holding_company.name)

        expect(client_csv).to be_valid
      end
    end
  end

  context 'importing new client' do
    it 'creates a new client from csv' do
      expect do
        client_csv.perform
      end.to change(Client, :count).by(1)

      new_client = Client.last
      expect(new_client.name).to eq client_csv.name
      expect(new_client.parent_client.name).to eq client_csv.parent
      expect(new_client.client_category.name).to eq client_csv.category
      expect(new_client.client_subcategory.name).to eq client_csv.subcategory

      expect(new_client.address.street1).to eq client_csv.address
      expect(new_client.address.city).to eq client_csv.city
      expect(new_client.address.state).to eq client_csv.state
      expect(new_client.address.zip).to eq client_csv.zip
      expect(new_client.address.phone).to eq client_csv.phone.gsub(/[^0-9]/, '')
      expect(new_client.website).to eq client_csv.website

      expect(new_client.client_members.first.user.email).to eq(new_client_csv[:teammembers].split('/')[0])
      expect(new_client.client_members.first.share).to eq(new_client_csv[:teammembers].split('/')[1].to_i)
    end
  end

  def client_csv(opts={})
    defaults = {
      company_id: company.id
    }
    @_client_csv ||= build :client_csv, defaults.merge(opts)
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

  def category
    @_category ||= create :option, field: category_field, company_id: company.id
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

  def region
    @_region ||= create :option, field: region_field, company_id: company.id
  end

  def segment
    @_segment ||= create :option, field: segment_field, company_id: company.id
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
end
