class SalesProcess < ActiveRecord::Base
  belongs_to :company
  has_many :stages
  has_many :teams

  validates :name, presence: true
  validate :duplicate_default_sales_process, on: :create

  scope :is_active, -> (status) { where(active: status) unless status.nil? }
  
  before_destroy :check_default_sales_process

  private

  def duplicate_default_sales_process
    if name == 'DEFAULT' && SalesProcess.where(name: 'DEFAULT', company: company).count > 0
      errors.add(:name, "can not be used again")
    end
  end

  def check_default_sales_process
    name != 'DEFAULT'
  end
end
