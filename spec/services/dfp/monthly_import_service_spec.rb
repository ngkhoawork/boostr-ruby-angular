require 'rails_helper'

describe DFP::MonthlyImportService, dfp: :true do
  before do
    create_io

    allow(File).to receive(:open).with(report_file, 'r:ISO-8859-1').and_return(report_csv)
  end

  it 'create new display line item budget successfully' do
    expect{
      monthly_import = described_class.new(company.id, 'dfp_monthly', report_file: report_file)
      monthly_import.perform
    }.to change(DisplayLineItemBudget, :count).by(1)

    display_line_item_budget = DisplayLineItemBudget.last

    expect(display_line_item_budget.external_io_number).to eq 1234
    expect(display_line_item_budget.start_date).to eq Date.new(2017, 03)
    expect(display_line_item_budget.end_date).to eq Date.new(2017, 03).end_of_month
    expect(display_line_item_budget.clicks).to eq 1000
    expect(display_line_item_budget.ctr.to_f).to eq 0.0192
    expect(display_line_item_budget.quantity).to eq 10000
    expect(display_line_item_budget.ad_server_quantity).to eq 10000
    expect(display_line_item_budget.budget.to_i).to eq 50000
    expect(display_line_item_budget.budget_loc.to_i).to eq 50000
    expect(display_line_item_budget.video_avg_view_rate).to eq 0.0120
    expect(display_line_item_budget.video_completion_rate).to eq 0.0034
  end

  it 'update display line item budget successfully' do
    display_line_item.display_line_item_budgets << display_line_item_budget

    monthly_import = described_class.new(company.id, 'dfp_monthly', report_file: report_file)
    monthly_import.perform

    expect(display_line_item_budget.reload.ad_server_quantity).to eq 10000
  end

  private

  def company
    @_company ||= create :company
  end

  def create_io
    @_io ||= create :io,
                    company: company,
                    external_io_number: 1234,
                    deal: deal,
                    display_line_items: [display_line_item]
  end

  def user
    @_user ||= create :user, company: company
  end

  def deal
    @_deal ||= create :deal,
                      creator: user,
                      budget: 20_000,
                      company: company
  end

  def display_line_item
    @_display_line_item ||= create(
      :display_line_item,
      price: 5,
      line_number: 4321,
      product: display_line_item_product
    )
  end

  def display_line_item_product
    @_display_line_item_product ||= create :product, company: company, revenue_type: 'Test Line'
  end

  def report_csv
    @_report_csv ||= generate_csv(build :dfp_report_monthly_csv_data)
  end

  def report_file
    './tmp/report.csv'
  end

  def display_line_item_budget
    @_display_line_item_budget ||= create :display_line_item_budget,
                                          ad_server_quantity: 500,
                                          start_date: Date.new(2017, 03),
                                          end_date: Date.new(2017, 03).end_of_month
  end
end
