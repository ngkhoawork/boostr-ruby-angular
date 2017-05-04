class AddHoldingCompanyIdToClient < ActiveRecord::Migration
  def change
    add_reference :clients, :holding_company, index: true
  end
end
