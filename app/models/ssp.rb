class Ssp < ActiveRecord::Base
  PARSER_TYPES = {
    'Rubicon' => 'rubicon',
    'SpotX' => 'spotx_aws',
    'AdX' => 'dfp_adx'
  }.freeze

  has_many :ssp_credentials

	validates :name, presence: true

  def adx?
    name.eql?('AdX')
  end

  def parser_type
    PARSER_TYPES[name]
  end
end
