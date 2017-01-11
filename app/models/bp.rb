class Bp < ActiveRecord::Base
  belongs_to :time_period
  belongs_to :company
  has_many :bp_estimates
  has_many :bp_estimate_products, through: :bp_estimates

  validates :time_period_id, :name, :due_date, presence: true

  after_create :generate_bp_estimates

  def merge_recursively(a, b)
    a.merge(b) {|key, a_item, b_item| merge_recursively(a_item, b_item) }
  end

  def as_json(options = {})
    super(merge_recursively( options,
        {
            include: {time_period: {}},
            methods: [:client_count, :status]
        }
    ))
  end

  def full_json
    self.as_json( {include: {
        bp_estimates: {
            include: {
                bp_estimate_products: {
                    include: {
                        product: {}
                    }
                },
                client: {},
                user: {}
            },
            methods: [:client_name, :user_name]
        },
    }})
  end

  def client_count
    client_count = bp_estimates.select("count(distinct(client_id)) as client_number").map{ |data| data.client_number}
    client_count[0]
  end

  def status
    status = bp_estimates.assigned.select("(count(CASE WHEN estimate_seller > 0 THEN 1 END) = count(user_id)) as is_complete").group("client_id").select{|row| row.is_complete == true }.size
    status
  end

  def generate_bp_estimates
    BPGenerator.perform_async(self.id)
  end

end
