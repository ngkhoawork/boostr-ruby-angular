require 'rails_helper'

describe 'OperativeDatafeedFulldayCompanyWorker' do
  it 'is in default queue' do
    expect(worker.sidekiq_options_hash['queue']).to eq 'default'
  end

  it 'is in specialized queue in production' do
    worker.set(queue: 'daily:operative_datafeed_generator').perform_async(15)

    expect(Sidekiq::Worker.jobs.size).to be 1

    expect(Sidekiq::Worker.jobs.first['queue']).to eq 'daily:operative_datafeed_generator'
  end

  private

  def worker
    @worker ||= OperativeDatafeedFulldayCompanyWorker
  end
end
