class ChangeFilterParamsDataTypeForFilterQuery < ActiveRecord::Migration
  def change
    change_column :filter_queries, :filter_params, :text
    change_column_null :filter_queries, :filter_params, true
    change_column_default :filter_queries, :filter_params, nil
  end
end
