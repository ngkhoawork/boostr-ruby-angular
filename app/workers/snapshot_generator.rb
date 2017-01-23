class SnapshotGenerator < BaseWorker
  def perform(day=nil)
    day ||= Date.today.wday

    Company.where(snapshot_day: day).each do |company|
      Snapshot.generate_snapshots(company)
    end
  end
end