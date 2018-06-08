require 'rails_helper'

RSpec.describe OperativeDatafeedConfiguration, type: :model do
  it 'creates jobs in default queue' do
    subject.start_job

    expect(Sidekiq::Worker.jobs.find{ |job| job['jid'] == subject.job_id }['queue']).to eq 'default'
  end

  it 'creates jobs in specialized queue in production' do
    Rails.env = 'production'

    jid = subject.start_job

    expect(Sidekiq::Worker.jobs.find{ |job| job['jid'] == subject.job_id }['queue']).to eq 'daily:operative_datafeed_generator'

    Rails.env = 'test'
  end

  def subject
    @subject ||= create :operative_datafeed_configuration, company: company
  end

  def company
    @company ||= create :company
  end
end
