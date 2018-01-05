class AddDateFieldsToPublisher < ActiveRecord::Migration
  def change
    add_column :publishers, :revenue_share, :string
    add_column :publishers, :term_start_date, :date
    add_column :publishers, :term_end_date, :date
  end
end
