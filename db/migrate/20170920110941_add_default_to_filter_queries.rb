class AddDefaultToFilterQueries < ActiveRecord::Migration
  def change
    add_column :filter_queries, :default, :boolean, default: false
  end
end
