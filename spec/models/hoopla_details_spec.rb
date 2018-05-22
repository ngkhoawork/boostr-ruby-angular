require 'rails_helper'

RSpec.describe HooplaDetails, type: :model do
  describe 'callbacks' do
    describe '#process_credentials' do
      subject { instance.save }

      before { instance.attributes = { client_id: '***client_id***', client_secret: '***client_secret***' } }

      context 'when oauth is successful' do
        before { allow_any_instance_of(Hoopla::Endpoints::Oauth).to receive(:perform) { successful_oauth } }

        it { expect{ subject }.to change{ instance.connected }.to(true) }
      end

      context 'when oauth is failed' do
        before { allow_any_instance_of(Hoopla::Endpoints::Oauth).to receive(:perform) { failed_oauth } }

        it { expect{ subject }.not_to change{ instance.connected } }
      end
    end
  end

  private

  def instance
    @instance ||= described_class.new
  end

  def successful_oauth
    double(:successful_oauth, code: '200', body: { access_token: '***token***', expires_in: 1800 })
  end

  def failed_oauth
    double(:failed_oauth, code: '401', body: {})
  end
end
