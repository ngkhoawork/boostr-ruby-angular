require 'rails_helper'

describe Api::IosController do
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
end
