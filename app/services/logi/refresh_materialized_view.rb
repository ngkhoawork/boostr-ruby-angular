class Logi::RefreshMaterializedView
  def self.perform
    ActiveRecord::Base.connection.execute <<-SQL
      REFRESH MATERIALIZED VIEW vw_prod_mon_sum_sa_2017;
    SQL
  end
end
