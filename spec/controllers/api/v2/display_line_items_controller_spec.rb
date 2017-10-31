require 'rails_helper'

RSpec.describe Api::V2::DisplayLineItemsController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:product_params) { attributes_for :product }

  before do
    valid_token_auth user
  end

  describe 'GET #create' do
    it 'posts attributes' do
      post :create, display_line_item: display_line_item_params

      expect(response).to be_success
    end

    it 'creates new line item' do
      expect do
        post :create, display_line_item: display_line_item_params()
      end.to change(DisplayLineItem, :count).by(1)
    end
  end

  def display_line_item_params(opts={})
    defaults = {
      budget: 10_000,
      budget_delivered: 5_000,
      product_name: 'Sponsored Content',
      external_io_number: io.external_io_number,
      start_date: io.start_date,
      end_date: io.end_date
    }

    @_display_line_item_params ||= attributes_for :display_line_item, defaults.merge(opts)
  end

  def io(opts={})
    defaults = {
      company_id: user.company_id,
      start_date: (Date.today - 1.month),
      end_date:   (Date.today + 1.month)
    }

    @_io = create :io, defaults.merge(opts)
  end
end
