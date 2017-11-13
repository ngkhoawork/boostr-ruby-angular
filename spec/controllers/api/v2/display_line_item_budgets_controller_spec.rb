require 'rails_helper'

RSpec.describe Api::V2::DisplayLineItemBudgetsController, type: :controller do
  before do
    valid_token_auth user
  end

  describe 'POST #create' do
    context 'valid data' do
      it 'posts attributes' do
        post :create, display_line_item_budget: display_line_item_budget_params

        expect(response).to be_success
      end

      it 'creates new line item budget' do
        expect do
          post :create, display_line_item_budget: display_line_item_budget_params
        end.to change(DisplayLineItemBudget, :count).by (1)
      end

      it 'logs a successful import' do
        expect do
          post :create, display_line_item_budget: display_line_item_budget_params
        end.to change(CsvImportLog, :count).by(1)

        log = CsvImportLog.first
        expect(log.source).to eql 'api'
        expect(log.rows_imported).to be 1
      end
    end

    context 'invalid data' do
      it 'does not create a line item' do
        expect do
          post :create, display_line_item_budget: display_line_item_budget_params(month_and_year: nil)
        end.not_to change(DisplayLineItemBudget, :count)
      end

      it 'logs an error' do
        expect do
          post :create, display_line_item_budget: display_line_item_budget_params(month_and_year: nil)
        end.to change(CsvImportLog, :count).by(1)

        log = CsvImportLog.first
        expect(log.source).to eql 'api'
        expect(log.rows_imported).to be 0
        expect(log.rows_failed).to be 1
        expect(log.error_messages.map{|el| el['message']}.flatten).to include "Month and year can't be blank"
      end
    end
  end

  def display_line_item_budget_params(opts={})
    defaults = {
      budget: 5_000,
      line_number: display_line_item.line_number,
      start_date: display_line_item.start_date,
      end_date: display_line_item.start_date.end_of_month
    }

    @_display_line_item_budget_params ||= attributes_for :display_line_item_budget_csv, defaults.merge(opts)
  end

  def display_line_item
    @_display_line_item ||= create :display_line_item, price: 20, io_id: io.id
  end

  def company
    @_company ||= create :company
  end

  def io
    @_io ||= create :io, company_id: company.id, external_io_number: 155555555
  end

  def external_io_number
    io.external_io_number
  end

  def user
    @_user ||= create :user, company_id: company.id
  end
end
