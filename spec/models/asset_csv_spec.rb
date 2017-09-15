require 'rails_helper'

RSpec.describe AssetCsv, type: :model do
  it { should validate_presence_of(:original_file_name) }
  it { should validate_presence_of(:attachable_id) }
  it { should validate_presence_of(:attachable_type) }
  it { should validate_presence_of(:company_id) }
  
  context 'custom validations' do
    context 'asset presence' do
      it 'is valid when company has a matching unmapped asset' do
        asset_csv(attachable_id: deal.id)
        unmapped_asset(asset_csv)

        expect(asset_csv).to be_valid
      end

      it 'is invalid when company has no matching unmapped asset' do
        asset_csv(attachable_id: deal.id, original_file_name: 'N/A')
        expect(asset_csv).not_to be_valid
        expect(asset_csv.errors.full_messages).to eql(["Asset with name N/A not found or is already mapped"])
      end
    end

    context 'creator exists' do
      it 'is valid if email maps to a user' do
        asset_csv(attachable_id: deal.id, uploader_email: user.email)
        unmapped_asset(asset_csv)

        expect(asset_csv).to be_valid
      end

      it 'is invalid if user is not found' do
        asset_csv(attachable_id: deal.id, uploader_email: 'N/A')
        unmapped_asset(asset_csv)

        expect(asset_csv).not_to be_valid
        expect(asset_csv.errors.full_messages).to eql(["Can't find user with email N/A"])
      end
    end

    context 'attachable type is either Deal or Activity' do
      it 'is valid if type is correct' do
        asset_csv(attachable_id: deal.id, attachable_type: 'Deal')
        unmapped_asset(asset_csv)

        expect(asset_csv).to be_valid
      end

      it 'is invalid if type is wrong' do
        asset_csv(attachable_id: deal.id, attachable_type: 'Error')
        unmapped_asset(asset_csv)

        expect(asset_csv).not_to be_valid
        expect(asset_csv.errors.full_messages).to eql(["Attachable type Error does not exist"])
      end
    end

    context 'attachable object presence' do
      it 'is invalid if attachable is not found' do
        asset_csv(attachable_id: 0)
        unmapped_asset(asset_csv)

        expect(asset_csv).not_to be_valid
        expect(asset_csv.errors.full_messages).to eql(["Can't find Deal with ID 0"])
      end

      it 'is valid with Activity object' do
        asset_csv(attachable_id: activity.id, attachable_type: 'Activity')
        unmapped_asset(asset_csv)

        expect(asset_csv).to be_valid
      end
    end
  end

  describe 'perform' do
    it 'finds and updates an unmapped asset from name' do
      asset_csv(attachable_id: deal.id)
      unmapped_asset(asset_csv)
      asset_csv.perform

      expect(unmapped_asset.reload.attachable_id).to be deal.id
      expect(unmapped_asset.reload.attachable_type).to eql 'Deal'
    end

    it 'sets creator email' do
      asset_csv(attachable_id: deal.id, uploader_email: user.email)
      unmapped_asset(asset_csv)
      asset_csv.perform

      expect(unmapped_asset.reload.created_by).to be user.id
    end

    it 'updates last item from two unmapped assets with same name' do
      asset_csv(attachable_id: deal.id)
      unmapped_assets(asset_csv)
      asset_csv.perform

      expect(unmapped_assets.last.reload.attachable_id).to be deal.id
      expect(unmapped_assets.last.reload.attachable_type).to eql 'Deal'

      expect(unmapped_assets.first.reload.attachable_id).to be nil
      expect(unmapped_assets.first.reload.attachable_type).to be nil
    end

    it 'skips assigning null created_at' do
      asset_csv(attachable_id: deal.id, created_at: nil)
      unmapped_asset(asset_csv)
      old_date = unmapped_asset.created_at
      asset_csv.perform

      expect(unmapped_asset.reload.created_at).to be_within(1.second).of old_date
    end

    it 'parses dates in problematic formats' do
      asset_csv(attachable_id: deal.id, created_at: '12/15/17')
      unmapped_asset(asset_csv)
      asset_csv.perform

      expect(unmapped_asset.reload.created_at.to_date).to eq Date.new(2017, 12, 15)
    end
  end

  def asset_csv(opts={})
    opts[:company_id] = company.id
    @_asset_csv ||= build :asset_csv, opts
  end

  def company(opts={})
    @_company ||= create :company
  end

  def deal(opts={})
    opts[:company_id] = company.id
    @_deal ||= create :deal, opts
  end

  def activity(opts={})
    @_activity ||= create :activity, company_id: company.id, deal: nil, client: nil
  end

  def unmapped_asset(asset_csv={})
    @_unmapped_asset ||= create :asset,
      original_file_name: asset_csv.original_file_name,
      company_id: company.id
  end

  def unmapped_assets(asset_csv={})
    @_unmapped_assets ||= create_list :asset, 5,
      original_file_name: asset_csv.original_file_name,
      company_id: company.id
  end

  def user
    @_user ||= create :user, company_id: company.id
  end
end
