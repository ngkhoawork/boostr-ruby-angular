require 'rails_helper'

RSpec.describe DisplayLineItemBudgetCsvOperative, type: :model do
  it { should validate_presence_of(:company_id) }
  it { should validate_presence_of(:line_number) }
  it { should validate_presence_of(:month_and_year) }
  it { should validate_presence_of(:budget_loc) }

  it { should_not validate_presence_of(:impressions) }

  def company(opts={})
    @_company ||= create :company
  end

  def subject(opts={})
    defaults = {
      company_id: company.id
    }
    @_subject ||= build :display_line_item_budget_csv_operative, defaults.merge(opts)
  end
end
