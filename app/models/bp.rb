class Bp < ActiveRecord::Base
  belongs_to :time_period
  belongs_to :company
  has_many :bp_estimates
  has_many :bp_estimate_products, through: :bp_estimates

  validates :time_period_id, :name, :due_date, presence: true

  after_create :generate_bp_estimates

  def as_json(options = {})
    super(options.merge(
        include: [:time_period],
        methods: [:client_count, :status]
    ))
  end

  def client_count
    client_count = bp_estimates.select("count(distinct(client_id)) as client_number").map{ |data| data.client_number}
    client_count[0]
  end

  def status
    status = bp_estimates.select("(count(CASE WHEN estimate_seller IS NOT NULL THEN 1 END) = count(user_id)) as is_complete").group("client_id").select{|row| row.is_complete == true }.size
    status
  end

  def generate_bp_estimates
    BPGenerator.perform_async(self.id)
  end

end
