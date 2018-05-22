class Logi::RefreshMaterializedView
  def self.perform
    db = ActiveRecord::Base.establish_connection
    connection = db.connection
    connection.execute('REFRESH MATERIALIZED VIEW vw_prod_mon_sum_sa_2017;')
  end
end