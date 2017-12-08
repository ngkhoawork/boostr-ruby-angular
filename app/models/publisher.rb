class Publisher < ActiveRecord::Base
  include PgSearch
  acts_as_paranoid

  has_one :address, as: :addressable, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :daily_actuals, class_name: 'PublisherDailyActual'
  has_many :contacts
  has_many :publisher_members, dependent: :destroy
  has_many :users, through: :publisher_members
  has_one :publisher_custom_field, dependent: :destroy, inverse_of: :publisher

  has_one :type_field,
          -> { where(subject_type: 'Publisher', name: 'Publisher Type') },
          through: :company, source: :fields
  has_one :renewal_term_field,
          -> { where(subject_type: 'Publisher', name: 'Renewal Terms') },
          through: :company, source: :fields

  has_many :available_types, through: :type_field, source: :options
  has_many :available_renewal_terms, through: :renewal_term_field, source: :options

  belongs_to :client
  belongs_to :company, required: true
  belongs_to :publisher_stage
  belongs_to :type, class_name: 'Option'
  belongs_to :renewal_term, class_name: 'Option'

  validates :name, presence: true
  validates :website, format: {
                        with: REGEXP_FOR_URL, message: 'Valid URL required', multiline: true, allow_blank: true
                      }

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :publisher_members, allow_destroy: true
  accepts_nested_attributes_for :publisher_custom_field

  pg_search_scope :search_by_name,
                  against: :name,
                  using: {
                    tsearch: {
                      dictionary: :english,
                      prefix: true,
                      any_word: true
                    },
                    dmetaphone: {
                      any_word: true
                    }
                  },
                  ranked_by: ':trigram'
end
