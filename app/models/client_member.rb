class ClientMember < ActiveRecord::Base
  belongs_to :client, touch: true
  belongs_to :user

  has_many :values, as: :subject

  validates :share, :user_id, :client_id, presence: true

  accepts_nested_attributes_for :values, reject_if: proc { |attributes| attributes['option_id'].blank? }

  def as_json(options = {})
    super(options.merge(include: {
                                client: {},
                                user: {
                                        methods: [:name]
                                },
                                values: {
                                        include: [:option],
                                        methods: [:value]
                                }
                        }))
  end

  def defaults
    { user_id: user_id, share: share }
  end

  def fields
    user.company.fields.where(subject_type: 'Client')
  end

  def role_value_defaults
    role_field = fields.where(name: 'Member Role').first
    value = values.where(field: role_field).first
    value.dup.attributes if value.present?
  end
end
