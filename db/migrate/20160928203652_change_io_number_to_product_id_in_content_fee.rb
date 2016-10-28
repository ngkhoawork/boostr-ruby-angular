class ChangeIoNumberToProductIdInContentFee < ActiveRecord::Migration
  def change
    rename_column :content_fees, :io_number, :product_id
  end
end
