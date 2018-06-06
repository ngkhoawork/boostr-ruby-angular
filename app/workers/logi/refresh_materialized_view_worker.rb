class Logi::RefreshMaterializedViewWorker < BaseWorker
  def perform
    Logi::RefreshMaterializedView.perform
  end
end
