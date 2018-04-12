class Stage < ActiveRecord::Base
  belongs_to :company
  belongs_to :sales_process
  has_many :deals

  default_scope { order('active, position') }
  scope :closed_won_for_company, -> (company_id) { where(company_id: company_id, active: true, open: false, probability: 100) }
  scope :for_company, -> (company_id) { where(company_id: company_id) }
  scope :is_open, -> (status) { where(open: status) unless status.nil? }
  scope :active, -> { where(active: true) }
  scope :by_ids, -> (ids) { where(id: ids) if ids.present? }
  scope :order_by_probability, -> { order(:probability) }

  validates :name, presence: true

  before_create :set_position

  after_create do
    create_dimension
  end

  after_destroy do |stage_record|
    delete_dimension(stage_record)
  end

  def closed?
    !open?
  end

  def create_dimension
    StageDimension.create(
      id: self.id,
      company_id: self.company_id,
      name: self.name,
      probability: self.probability,
      open: self.open
    )
  end

  def delete_dimension(stage_record)
    StageDimension.destroy(stage_record.id)
    ForecastPipelineFact.destroy_all(stage_dimension_id: stage_record.id)
  end

  def self.closed_won(company_id)
    self.closed_won_for_company(company_id).first
  end

  def color
    attributes[:color] || color_for_probability
  end

  private

  def orange
    "#FF7E30"
  end

  def color_for_probability
    shade_blend((100.0 - probability) / 100.0, orange) if probability
  end

  def shade_blend(factor,color,blend_color=nil)
    # Invert if we are darkening
    n = factor < 0 ? factor * -1 : factor

    color_value = color.gsub('#', '').hex
    blend_color_value = (blend_color ? blend_color : factor < 0 ? "#000000" : "#FFFFFF").gsub('#', '').hex
    r1 = color_value >> 16
    g1 = color_value >> 8 & 0x00FF
    b1 = color_value & 0x0000FF

    res_r = ((((blend_color_value >> 16)-r1)*n).round+r1)*0x10000
    res_g = ((((blend_color_value >> 8 & 0x00FF)-g1)*n).round+g1)*0x100
    res_b = ((((blend_color_value & 0x0000FF)-b1)*n).round+b1)
    res = res_r + res_g + res_b

    "#"+res.to_s(16)
  end

  def set_position
    self.position ||= Stage.count
  end
end


