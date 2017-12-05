require 'rails_helper'

describe Importers::PublisherDailyActualsService do
  describe '#perform' do
    before(:each) do
      @file = File.open(file_path, 'w') do |f|
        f.puts(
          "date,\
           available_impressions,\
           filled_impressions,\
           company_id,\
           publisher_id,\
           publisher_name,\
           total_revenue,\
           curr_symbol,\
           ecpm"
        )
        f.puts(
          "#{us_string_date},\
           #{available_impressions},\
           #{filled_impressions},\
           #{company_id},\
           #{publisher_id},\
           #{publisher_name},\
           #{total_revenue},\
           #{curr_symbol},\
           #{ecpm}"
        )
      end
    end
    after(:each) { FileUtils.rm(file_path) if File.exist?(file_path) }

    subject { instance.perform }

    it do
      expect{subject}.to change{PublisherDailyActual.count}.by(1)
      expect(last_publisher_daily_actual.date).to eq date
      expect(last_publisher_daily_actual.available_impressions).to eq available_impressions
      expect(last_publisher_daily_actual.filled_impressions).to eq filled_impressions
      expect(last_publisher_daily_actual.total_revenue).to eq total_revenue
      expect(last_publisher_daily_actual.currency).to eq currency
      expect(last_publisher_daily_actual.ecpm).to eq ecpm
    end

    context 'when there is daily actual for this date' do
      let!(:daily_actual) do
        create(
          :publisher_daily_actual,
          publisher: publisher,
          date: date,
          available_impressions: 10,
          filled_impressions: 7,
          total_revenue: rand(1..1000),
          ecpm: rand(1..1000),
          currency: currency
        )
      end

      it { expect{subject}.not_to change{PublisherDailyActual.count} }
      it do
        expect{subject}.to change{
          daily_actual.reload.available_impressions
        }.to(available_impressions)
        .and change{
          daily_actual.reload.filled_impressions
        }.to(filled_impressions)
      end
    end

    context 'when publisher_id, publisher_name are absent' do
      let(:publisher_id) { nil }
      let(:publisher_name) { nil }

      it { expect{subject}.not_to change{PublisherDailyActual.count} }
    end

    context 'when company_id is absent' do
      let(:company_id) { nil }

      it { expect{subject}.not_to change{PublisherDailyActual.count} }
    end
  end

  private

  def params
    { file: file_path, company_id: company_id, import_subject: 'PublisherDailyActual' }
  end

  def instance
    described_class.new(params)
  end

  def file
    @file
  end

  def last_publisher_daily_actual
    @last_publisher_daily_actual ||= PublisherDailyActual.last
  end

  def company
    @company ||= create(:company)
  end

  def company_id
    company.id
  end

  def publisher
    @publisher ||= create(:publisher, name: 'Amazon', company: company)
  end

  def currency
    @currency ||= Currency.first || create(:currency)
  end

  def publisher_id
    publisher.id
  end

  def publisher_name
    publisher.name
  end

  def total_revenue
    1000
  end

  def curr_symbol
    currency.curr_symbol
  end

  def ecpm
    50
  end

  def date
    1.day.ago.to_date
  end

  def us_string_date
    date.strftime('%m/%d/%Y')
  end

  def available_impressions
    100
  end

  def filled_impressions
    80
  end

  def file_path
    @file_path ||= 'tmp/PublisherDailyActualsImport.csv'
  end
end
