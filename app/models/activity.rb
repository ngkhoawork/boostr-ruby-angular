class Activity < ActiveRecord::Base

  belongs_to :company
  belongs_to :user
  belongs_to :client
  belongs_to :agency, class_name: 'Client', foreign_key: 'agency_id'
  belongs_to :deal
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  belongs_to :updator, class_name: 'User', foreign_key: 'updated_by'
  belongs_to :activity_type

  has_and_belongs_to_many :contacts

  has_many :reminders, as: :remindable, dependent: :destroy
  has_many :assets, as: :attachable

  validates :company_id, presence: true
  validates_uniqueness_of :google_event_id, allow_nil: true, allow_blank: true

  after_create do
    if !deal_id.nil?
      deal = company.deals.find(deal_id)
      deal.update_attribute(:activity_updated_at, happened_at)
    elsif !client_id.nil?
      client = company.clients.find(client_id)
      client.update_attribute(:activity_updated_at, happened_at)
    end
  end

  def as_json(options = {})
    super(options.merge(
      include: {
        :client => {},
        :agency => {},
        :deal => {
          :include => [
            :stage,
            :advertiser
          ]
        },
        :assets => {
            methods: [
                :presigned_url
            ]
        },
        :contacts => {
          include: { address: {} }
          },
        :creator => {}
      }
    ))
  end
end
