class Contract < ActiveRecord::Base
  include PgSearch
  acts_as_paranoid

  belongs_to :company, required: true
  belongs_to :advertiser, class_name: 'Client'
  belongs_to :agency, class_name: 'Client'
  belongs_to :deal
  belongs_to :publisher
  belongs_to :holding_company
  belongs_to :type, class_name: 'Option', required: true
  belongs_to :status, class_name: 'Option'

  has_one :currency, class_name: 'Currency', primary_key: 'curr_cd', foreign_key: 'curr_cd'

  has_many :contract_members, inverse_of: :contract, dependent: :destroy
  has_many :contract_contacts, inverse_of: :contract, dependent: :destroy
  has_many :special_terms, inverse_of: :contract, dependent: :destroy
  has_many :assets, as: :attachable, dependent: :destroy

  has_many :users, through: :contract_members, source: :user

  validates :name, presence: true

  accepts_nested_attributes_for :contract_members, allow_destroy: true
  accepts_nested_attributes_for :contract_contacts, allow_destroy: true
  accepts_nested_attributes_for :special_terms, allow_destroy: true

  def self.search_by_name_options
    {
      against: :name,
      using: {
        tsearch: {
          prefix: true,
          any_word: true
        },
        dmetaphone: {
          any_word: true
        }
      },
      ranked_by: ':trigram'
    }
  end

  pg_search_scope :search_by_name, search_by_name_options
end
