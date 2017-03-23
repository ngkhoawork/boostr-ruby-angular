require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

every(1.day, 'Snapshot Generator', at: '8:00', tz: 'UTC') do
  SnapshotGenerator.perform_async
end

every(1.day, 'Deal Report Generator', at: '12:00', tz: 'UTC') do
  DealReportGenerator.perform_async
end

every(1.day, 'Operative DataFeed', at: '4:00', tz: 'UTC') do
  OperativeDatafeedWorker.perform_async
end

every(1.day, 'Account Dimension Synchronizer', at: '4:50', tz: 'UTC') do
  AccountSynchronizer.perform_async
end

every(1.day, 'Account Revenue Data Calculator', at: '5:00', tz: 'UTC') do
  RevenueDataWarehouse.perform_async
end

every(1.day, 'Account Pipeline Data Calculator', at: '5:10', tz: 'UTC') do
  AccountPipelineCalculator.perform_async
end
