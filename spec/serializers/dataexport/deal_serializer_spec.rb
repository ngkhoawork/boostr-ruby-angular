require 'rails_helper'

describe Dataexport::DealSerializer do
  before do
    serialized_custom_fields
    type
    source
  end

  it 'serializes deal data' do
    expect(serializer.id).to eq(deal.id)
    expect(serializer.name).to eq(deal.name)
    expect(serializer.advertiser_id).to eq(deal.advertiser_id)
    expect(serializer.agency_id).to eq(deal.agency_id)
    expect(serializer.start_date).to eq(deal.start_date)
    expect(serializer.end_date).to eq(deal.end_date)
    expect(serializer.budget_usd).to eq(deal.budget)
    expect(serializer.budget).to eq(deal.budget_loc)
    expect(serializer.created).to eq(deal.created_at)
    expect(serializer.last_updated).to eq(deal.updated_at)
    expect(serializer.stage_id).to eq(deal.stage_id)
    expect(serializer.stage_name).to eq(deal.stage.name)
    expect(serializer.type).to eq(type)
    expect(serializer.source).to eq(source)
    expect(serializer.next_steps).to eq(deal.next_steps)
    expect(serializer.closed_date).to eq(deal.closed_at)
    expect(serializer.open).to eq(deal.open)
    expect(serializer.currency).to eq(deal.curr_cd)
    expect(serializer.initiative_id).to eq(deal.initiative_id)
    expect(serializer.closed_text).to eq(deal.closed_reason_text)
    expect(serializer.custom_fields).to eq(serialized_custom_fields)
  end

  private

  def serializer
    @_serializer ||= described_class.new(deal)
  end

  def deal
    @_deal ||= create :deal, company: company
  end

  def company
    @_company ||= create :company
  end

  def custom_field
    @_custom_field ||= create :deal_custom_field, company: company, deal: deal, text1: 'Some text'
  end

  def field_name
    @_field_name ||= create :deal_custom_field_name,
                            company: company,
                            field_index: 1,
                            field_type: 'text',
                            field_label: 'Text Field'
  end

  def serialized_custom_fields
    @_serialized_custom_fields ||= {
      field_name.field_label.downcase.gsub(' ', '_') => custom_field.public_send(field_name.field_name)
    }
  end

  def type
    return @_type if defined? @_type

    field = find_or_create_custom_field('Deal Source')
    create_value_for_field(field)

    @_type = deal.values.find_by(field_id: field.id).option.name
  end

  def source
    return @_source if defined? @_source

    field = find_or_create_custom_field('Deal Type')
    create_value_for_field(field)

    @_source = deal.values.find_by(field_id: field.id).option.name
  end

  def find_or_create_custom_field(field_name)
    field = deal.fields.find_or_initialize_by(name: field_name, value_type: 'Option')
    field.save unless field.persisted?
    field
  end

  def create_value_for_field(field)
    option = create :option, company: company, field: field, name: 'Option1'
    value = create :value, company: company, subject: deal, option: option, field: field
  end
end
