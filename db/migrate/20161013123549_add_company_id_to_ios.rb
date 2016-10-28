class AddCompanyIdToIos < ActiveRecord::Migration
  def change
    add_reference :ios, :company, foreign_key: true
  end
end
