class GoogleSpreadsheets::DealSerializer < ActiveModel::Serializer
  EMPTY = ''.freeze
  FIEDLS_ORDER = %w(id opportunity_title brand creative_ideas_needed launch seller csm parent agency region budget demo kpis empty empty empty empty empty empty empty empty empty empty empty empty vertical industry opportunityurl product empty empty empty empty empty pitchdate rfphighest empty bae opp_name probability strategic_planner).freeze

  attributes :id

  def to_spreadsheet
    # TODO Remove 'first(3)' when propper mapping will be finished
    { values: [FIEDLS_ORDER.first(3).map { |field_name| public_send(field_name) }] }
  end

  def empty
    EMPTY
  end

  def opportunity_title
    object.name
  end

  def brand
    object.company.name
  end
end
