class UpdateStages < ActiveRecord::Migration
  def up
    add_column :stages, :sales_process_id, :integer
    add_index :stages, :sales_process_id

    Company.all.each do |company|
      sales_process = SalesProcess.create!(name: 'DEFAULT', active: true, company: company)      
      Stage.where(company: company).update_all(sales_process_id: sales_process.id)
    end
  end

  def down
    SalesProcess.where(name: 'DEFAULT').destroy_all
    remove_column :stages, :sales_process_id
  end
end
