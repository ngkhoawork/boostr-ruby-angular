class UpdateDefaultFreezedForCompanies < ActiveRecord::Migration
  def change
    Company.all.update_all(default_io_freeze_budgets: true)
  end
end
