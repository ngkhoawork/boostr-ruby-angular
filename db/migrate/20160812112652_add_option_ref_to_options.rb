class AddOptionRefToOptions < ActiveRecord::Migration
  def change
    add_reference :options, :option, index: true
  end
end
