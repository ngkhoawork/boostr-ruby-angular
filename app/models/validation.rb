class Validation < ActiveRecord::Base
  belongs_to :company

  has_one :criterion, class_name: 'Value', as: :subject

  validates :company, :factor, presence: :true
  validates_uniqueness_of :factor, scope: [:company_id]

  accepts_nested_attributes_for :criterion

  after_create do
    self.create_criterion
  end

  def as_json(options = {})
    super(options.merge(
      include: {
        criterion: {
          methods: [:value]
        }
      }
    ))
  end
end
