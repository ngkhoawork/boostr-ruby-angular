require 'rails_helper'

describe Api::IosController do
  before { sign_in account_manager }

  describe 'GET #index' do
    before { create_list :io, 5, company: company }

    it 'has appropriate count of record in response' do
      get :index, format: :json

      response_json = response_json(response)

      expect(response_json.count).to eq(5)
    end

    it 'has ios related to specific advertiser' do
      create :io, company: company, advertiser: advertiser

      get :index, advertiser_id: advertiser.id, format: :json

      response_json = response_json(response)

      expect(response_json.count).to eq(1)
      expect(response_json.first['advertiser_id']).to eq(advertiser.id)
    end

    it 'has ios related to specific agency' do
      agency = company.ios.first.agency

      get :index, agency_id: agency.id, format: :json

      response_json = response_json(response)

      expect(response_json.count).to eq(1)
      expect(response_json.first['agency_id']).to eq(agency.id)
    end

    it 'has appropriate ios if filter by name' do
      create :io, company: company, name: 'Deal 234'

      get :index, name: '234', format: :json

      response_json = response_json(response)

      expect(response_json.count).to eq(1)
    end

    it 'has appropriate ios if filter by started date' do
      create :io, company: company, start_date: '2015-06-15'

      get :index, end_date: '2015-06-20', start_date: '2015-06-10', format: :json

      response_json = response_json(response)

      expect(response_json.count).to eq(1)
    end
  end

  describe 'DELETE #destroy' do
    context 'user with admin role' do
      before { sign_in admin_user }

      it 'delete io successfully' do
        io = create :io, company: company, display_line_items: [display_line_item]
        create :content_fee, io: io
        io_member = create :io_member, user: admin_user, io: io
        io.io_members << io_member

        expect{
          delete :destroy, id: io.id, format: :json
        }.to change(Io, :count).by(-1)
        .and change(DisplayLineItem, :count).by(-1)
        .and change(IoMember, :count).by(-1)
        .and change(ContentFee, :count).by(-1)
        .and change(ContentFeeProductBudget, :count).by(-1)
      end
    end

    context 'user without admin role' do
      before { sign_in account_manager }

      it 'unable to delete io' do
        io = create :io, company: company

        expect{
          delete :destroy, id: io.id, format: :json
        }.to_not change(Io, :count)
      end
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def admin_user
    @_admin_user ||= create :user, company: company, roles: ['admin']
  end

  def account_manager
    @_account_manager ||= create :user, company: company, user_type: ACCOUNT_MANAGER
  end

  def display_line_item
    @_display_line_item ||= create(
      :display_line_item,
      price: 10
    )
  end

  def advertiser
    @_advertiser ||= create :client, company: company
  end
end
