class IndexClientFuzzyName < ActiveRecord::Migration
  def change
    Client.bulk_update_fuzzy_name
  end
end
