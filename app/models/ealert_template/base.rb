class EalertTemplate::Base < ActiveRecord::Base
  self.table_name = 'ealert_templates'

  belongs_to :company, required: true

  has_many :fields,
           -> { order(position: :asc) },
           class_name: 'EalertTemplateField',
           foreign_key: :ealert_template_id,
           dependent: :destroy
  has_many :fields_with_position,
           -> { with_position.order(position: :asc) },
           class_name: 'EalertTemplateField',
           foreign_key: :ealert_template_id

  accepts_nested_attributes_for :fields

  before_create :initialize_fields

  private

  delegate :subject_class, :subject_decorator_class, :field_names, to: :class

  def initialize_fields
    fields.new(default_fields_attrs)
  end

  def default_fields_attrs
    field_names.map.with_index(1) do |core_field_name, position|
      { name: core_field_name, position: position }
    end
  end
end
