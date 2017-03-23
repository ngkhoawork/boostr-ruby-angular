class Stage < ActiveRecord::Base
  belongs_to :company
  has_many :deals

  default_scope { order('active, position') }
  scope :active, -> { where(active: true) }
  scope :closed_won_for_company, -> (company_id) { where(company_id: company_id, active: true, open: false, probability: 100) }

  validates :name, presence: true

  before_create :set_position

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


