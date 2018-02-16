require 'rails_helper'

RSpec.describe Api::V2::DisplayLineItemsController, type: :controller do
  let!(:io) { create(:io, company: company, start_date: (Date.today - 1.month), end_date: (Date.today + 1.month)) }
  let!(:io_member) { create(:io_member, io: io, user: user, from_date: io.start_date, to_date: io.end_date) }

  before { valid_token_auth user }

  describe 'POST #create' do
    let(:display_line_item_params) { default_display_line_item_params }

    subject { post :create, display_line_item: display_line_item_params }

    it do
      expect{subject}.to change(DisplayLineItem, :count).by(1)
      expect(response).to be_success
    end

    context 'when start_date param is earlier than io.start_date' do
      let(:display_line_item_params) { default_display_line_item_params.merge!(start_date: io.start_date - 1.day) }

      it 'updates io and io members start dates' do
        expect{subject}.to change{io.reload.start_date}.to(display_line_item_params[:start_date]).and \
                           change{io_member.reload.from_date}.to(display_line_item_params[:start_date])

      end
    end

    context 'when end_date param is later than io.end_date' do
      let(:display_line_item_params) { default_display_line_item_params.merge!(end_date: io.end_date + 1.day) }

      it 'updates io and io members end dates' do
        expect{subject}.to change{io.reload.end_date}.to(display_line_item_params[:end_date]).and \
                           change{io_member.reload.to_date}.to(display_line_item_params[:end_date])

      end
    end
  end

  private

  def company
    @_company ||= create(:company)
  end

  def user
    @_user ||= create(:user, company: company)
  end

  def default_display_line_item_params
    @_default_display_line_item_params ||=
      attributes_for(
        :display_line_item,
        budget: 10_000,
        budget_delivered: 5_000,
        product_name: 'Sponsored Content',
        external_io_number: io.external_io_number,
        start_date: io.start_date,
        end_date: io.end_date
      )
  end
end
