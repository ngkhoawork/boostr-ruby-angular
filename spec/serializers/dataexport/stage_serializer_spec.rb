require 'rails_helper'

describe Dataexport::StageSerializer do
  it 'serializes stage data' do
    expect(serializer.id).to eq(stage.id)
    expect(serializer.name).to eq(stage.name)
    expect(serializer.probability).to eq(stage.probability)
    expect(serializer.open).to eq(stage.open)
    expect(serializer.active).to eq(stage.active)
    expect(serializer.created).to eq(stage.created_at)
    expect(serializer.last_updated).to eq(stage.updated_at)
  end

  private

  def serializer
    @_serializer ||= described_class.new(stage)
  end

  def stage
    @_stage ||= create :stage
  end
end
