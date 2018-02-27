class Csv::ActivePmpObject
  include ActiveModel::Validations
  include Csv::Pmp

  attr_accessor :advertiser,
                :name,
                :agency,
                :start_date,
                :end_date,
                :company_id,
                :team

  validates :name, :team, :company_id, presence: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    record.save!
  end

  private

  def record
    Pmp.new(active_pmp_object_params)
  end

  def check_advertiser
    client = ::Client.find_by(name: advertiser,company_id: company_id)
    if client.present?
      client.id
    else
      raise_error("Advertiser")
    end
  end

  def check_agency
    ::Client.find_by(name: agency,company_id: company_id).id if agency.present? && agency != 'No Agency'
  end

  def create_pmp_members
    members = []
    if team.present?
      emails = team.split(';')
      emails.each do |email|
        user_email = email.split('/')[0]
        user_share = email.split('/')[1]
        if user_share.present?
          if user_share.to_i == 0 || user_share.to_i == 100
            user = search_user(user_email)
            if user.present?
              opts = {
                  user_id: user.id,
                  share: user_share.to_i,
                  from_date: check_and_format_date(start_date),
                  to_date: check_and_format_date(end_date),
                  skip_callback: true
              }
              members << PmpMember.new(opts)
            end
          else
            raise "Team Split must add up to either 0 or 100"
          end
        else
          raise "Team member #{user_email} share field"
        end
      end if emails.present?
      members
    else
      raise_error("Team members")
    end
  end

  def search_user(email)
    User.find_by(email: email)
  end

  def active_pmp_object_params
    {
        name: name,
        advertiser_id: check_advertiser,
        agency_id: check_agency,
        start_date: check_and_format_date(start_date),
        end_date: check_and_format_date(end_date),
        company_id: company_id,
        pmp_members: create_pmp_members,
        skip_callback: true
    }
  end

end
