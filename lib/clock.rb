require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  configure do |config|
    config[:tz] = 'UTC'
  end

  error_handler do |error|
    Rollbar.error(error)
  end

  every(1.day, 'Snapshot Generator', at: '8:00') do
    SnapshotGenerator.perform_async
  end

  every(1.day, 'Deal Report Generator', at: '12:00') do
    DealReportGenerator.perform_async
  end

  every(1.day, 'Operative DataFeed', at: '4:00') do
    OperativeDatafeedWorker.perform_async
  end

  every(1.day, 'Account Dimension Synchronizer', at: '4:50') do
    AccountSynchronizer.perform_async
  end

  every(1.day, 'Account Revenue Data Calculator', at: '5:00') do
    RevenueDataWarehouse.perform_async
  end

  every(1.day, 'Account Pipeline Data Calculator', at: '5:10') do
    AccountPipelineCalculator.perform_async
  end

  every(1.day, 'Dfp reports importer', at: '4:30') do
    DfpImportWorker.perform_async
  end
end
