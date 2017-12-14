require 'rails_helper'

RSpec.describe HooplaConfiguration, type: :model do
  describe 'validation' do
    describe '#connected_is_required_for_switched_on' do
      subject { instance.validate }

      before do
        instance.assign_attributes(switched_on: true, connected: false)
        allow_any_instance_of(Hoopla::Endpoints::Oauth).to receive(:perform) { failed_oauth }
      end

      it { expect{ subject }.to change{ instance.errors[:switched_on] }.from([]).to(['must be set after connected']) }
    end
  end

  private

  def instance
    @_instance ||= described_class.new
  end
end
