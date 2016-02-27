require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:company) { create :company }

  context 'validation' do
    it { should validate_presence_of(:name) }
  end

  it "set default value" do
    expect(company.notifications[0].name).to eq("Closed Won")
  end

end
