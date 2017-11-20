class Publisher < ActiveRecord::Base
  include PgSearch
  acts_as_paranoid

  has_one :address, as: :addressable, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :contacts
  has_many :publisher_members, dependent: :destroy
  has_many :users, through: :publisher_members
  has_one :publisher_custom_field, dependent: :destroy

  has_many :values, as: :subject
  has_one :type_field, -> { where(subject_type: 'Publisher', name: 'Publisher Type') },
          through: :company, source: :fields
  has_many :available_type_options, through: :type_field, source: :options
  has_one :type_value,
          -> { joins(:field).where(fields: { subject_type: 'Publisher', name: 'Publisher Type' }) },
          as: :subject,
          class_name: 'Value'

  belongs_to :client
  belongs_to :company
  belongs_to :stage, class_name: 'PublisherStage', foreign_key: 'stage_id'

  validates :name, :client_id, presence: true
  validates :website, format: {
                        with: REGEXP_FOR_URL, message: 'Valid URL required', multiline: true, allow_blank: true
                      }

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

  def type_option
    type_value.option
  end

  def type_option=(option)
    type_value.option = option
  end
end
