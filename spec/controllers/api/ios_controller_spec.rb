require 'rails_helper'

describe Api::IosController do
  before { sign_in account_manager }

  describe 'GET #index' do
    let!(:io) { create :io, company: company, advertiser: advertiser, agency: agency, name: 'Deal 234' }

    let(:params) { {} }
    subject { get :index, params }

    context 'when filter params are absent' do
      let!(:bunch_ios) { create_list(:io, 5, company: company) }

      it { subject; expect(response_json.count).to eq(6) }
    end

    context 'when params include advertiser id' do
      context 'which is related to an existing io' do
        let(:params) { { advertiser_id: advertiser.id } }

        it { subject; expect(response_ids).to include io.id }
      end

      context 'which is not related to an existing io' do
        let(:params) { { advertiser_id: -1 } }

        it { subject; expect(response_ids).not_to include io.id }
      end
    end

    context 'when params include agency id' do
      context 'which is related to an existing io' do
        let(:params) { { agency_id: agency.id } }

        it { subject; expect(response_ids).to include io.id }
      end

      context 'which is not related to an existing io' do
        let(:params) { { agency_id: -1 } }

        it { subject; expect(response_ids).not_to include io.id }
      end
    end

    context 'when params include budget' do
      context 'which is related to an existing io' do
        let(:params) { { budget_start: io.budget - 5, budget_end: io.budget + 5 } }

        it { subject; expect(response_ids).to include io.id }
      end

      context 'which is not related to an existing io' do
        let(:params) { { budget_start: io.budget - 5, budget_end: io.budget - 1 } }

        it { subject; expect(response_ids).not_to include io.id }
      end
    end

    context 'when params include name' do
      context 'which is related to an existing io' do
        let(:params) { { name: io.name } }

        it { subject; expect(response_ids).to include io.id }
      end

      context 'which is not related to an existing io' do
        let(:params) { { name: 'SOME_STRING' } }

        it { subject; expect(response_ids).not_to include io.id }
      end

      context 'which is related to an existing io advertiser' do
        let(:params) { { name: io.advertiser.name } }

        it { subject; expect(response_ids).to include io.id }
      end

      context 'which is related to an existing io agency' do
        let(:params) { { name: io.agency.name } }

        it { subject; expect(response_ids).to include io.id }
      end
    end

    context 'when params include range start_date' do
      context 'which is related to an existing io' do
        let(:params) { { start_date_start: io.start_date - 1.day, start_date_end: io.start_date + 1.day } }

        it { subject; expect(response_ids).to include io.id }
      end

      context 'which is not related to an existing io' do
        let(:params) { { start_date_start: io.start_date - 1.day, start_date_end: io.start_date - 0.5.day } }

        it { subject; expect(response_ids).not_to include io.id }
      end
    end

    context 'when params include range end_date' do
      context 'which is related to an existing io' do
        let(:params) { { end_date_start: io.end_date - 1.day, end_date_end: io.end_date + 1.day } }

        it { subject; expect(response_ids).to include io.id }
      end

      context 'which is not related to an existing io' do
        let(:params) { { end_date_start: io.end_date - 1.day, end_date_end: io.end_date - 0.5.day } }

        it { subject; expect(response_ids).not_to include io.id }
      end
    end

    context 'when params include io_number' do
      context 'which is related to an existing io' do
        let(:params) { { io_number: io.io_number } }

        it { subject; expect(response_ids).to include io.id }
      end

      context 'which is not related to an existing io' do
        let(:params) { { io_number: -1 } }

        it { subject; expect(response_ids).not_to include io.id }
      end
    end

    context 'when params include external_io_number' do
      context 'which is related to an existing io' do
        let(:params) { { external_io_number: io.external_io_number } }

        it { subject; expect(response_ids).to include io.id }
      end

      context 'which is not related to an existing io' do
        let(:params) { { external_io_number: -1 } }

        it { subject; expect(response_ids).not_to include io.id }
      end
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
          delete :destroy, id: io.id
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
          delete :destroy, id: io.id
        }.to_not change(Io, :count)
      end
    end
  end

  private

  def response_json
    @_response_json ||= super(response)
  end

  def response_ids
    @_response_ids ||= response_json.map { |resource| resource['id'] }
  end

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

  def agency
    @_agency ||= create :client, :agency, company: company
  end
end
