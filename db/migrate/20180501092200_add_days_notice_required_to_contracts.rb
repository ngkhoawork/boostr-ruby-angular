class AddDaysNoticeRequiredToContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :days_notice_required, :integer
  end
end
