require 'rails_helper'

describe 'OperativeDatafeedFulldayCompanyWorker' do
  it 'is in default queue' do
    expect(worker.sidekiq_options_hash['queue']).to eq 'default'
  end

  it 'is in specialized queue in production' do
    expect{
      worker.set(queue: 'daily:operative_datafeed_generator').perform_async(15)
    }.to change{Sidekiq::Worker.jobs.size}.by 1

    expect(Sidekiq::Worker.jobs.last['queue']).to eq 'daily:operative_datafeed_generator'
  end

  private

  def worker
    @worker ||= OperativeDatafeedFulldayCompanyWorker
  end
end
