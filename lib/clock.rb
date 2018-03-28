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

  every(1.day, 'Operative DataFeed Fullday', at: '4:00') do
    OperativeDatafeedFulldayWorker.perform_async
  end

  every(1.day, 'Account Dimension Synchronizer', at: '4:50') do
    AccountSynchronizer.perform_async
  end

  every(1.day, 'Account Revenue Data Calculator', at: '5:00') do
    RevenueDataWarehouse.perform_async
  end

  every(1.day, 'Product Dimension Synchronizer', at: '4:50') do
    ProductDimensionUpdaterWorker.perform_async
  end

  every(1.day, 'Account Pipeline Data Calculator', at: '5:10') do
    AccountPipelineCalculator.perform_async
  end

  every(1.day, 'Dfp reports importer', at: '4:30') do
    DfpImportWorker.perform_async
  end

  every(1.day, 'Account Product Pipeline Fact Updater', at: '5:20') do
    AccountProductPipelineCalculationWorker.perform_async
  end

  every(1.day, 'Account Product Revenue Fact Updater', at: '5:30') do
    AccountProductRevenueCalculationWorker.perform_async
  end

  every(1.day, 'Advertiser Agency Pipeline Fact Updater', at: '4:30') do
    AdvertiserAgencyPipelineCalculationWorker.perform_async
  end

  every(1.day, 'Advertiser Agency Revenue Fact Updater', at: '4:35') do
    AdvertiserAgencyRevenueCalculationWorker.perform_async
  end

  every(1.day, 'Stopped PMPs Alert', at: '8:00') do
    StoppedPmpDetectWorker.perform_async
  end

  every(1.day, 'Operative DataFeed Intraday', at: '14:00') do
    OperativeDatafeedIntradayWorker.perform_async
  end

  every(1.day, 'Operative DataFeed Intraday', at: '17:00') do
    OperativeDatafeedIntradayWorker.perform_async
  end

  every(1.day, 'Operative DataFeed Intraday', at: '20:00') do
    OperativeDatafeedIntradayWorker.perform_async
  end

  every(1.day, 'Operative DataFeed Intraday', at: '23:00') do
    OperativeDatafeedIntradayWorker.perform_async
  end
end
