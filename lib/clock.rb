require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

every(1.day, 'Snapshot Generator', at: '8:00', tz: 'UTC') do
  SnapshotGenerator.perform_async
end

every(1.day, 'Account Revenue Data Calculator', at: '15:00', tz: 'UTC') do
  RevenueDataWarehouse.perform_async
end

every(1.day, 'Account Pipeline Data Calculator', at: '14:30', tz: 'UTC') do
  AccountPipelineCalculator.perform_async
end
