class Csv::ActivePmpObject
  include ActiveModel::Validations
  include Csv::Pmp

  attr_accessor :advertiser,
                :name,
                :agency,
                :start_date,
                :end_date,
                :company_id,
                :team,
                :is_multibuyer

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
    Pmp.new(check_advertiser.present? ? active_pmp_object_params : active_pmp_object_params.merge!(ssp_advertiser: ssp_advertiser))
  end

  def account
    ::Client.find_or_create_by(name: 'Multi-Buyer', company_id: company_id)
  end

  def check_advertiser
    if is_multibuyer.eql?('yes')
      account.update_attribute(:is_multibuyer, true) if account.is_multibuyer.blank?
      account.id
    else
      ::Client.find_by(name: advertiser,company_id: company_id)&.id
    end
  end

  def ssp_advertiser
    SspAdvertiser.find_or_create_by(name: advertiser,company_id: company_id)
  end

  def check_agency
    ::Client.find_by(name: agency,company_id: company_id)&.id if agency.present? && agency != 'No Agency'
  end

  def create_pmp_members
    members = []

    raise_error("Team members") if team.blank?

    emails = team.split(';')

    return members if emails.blank?

    emails.each do |email|
      user_email, user_share = email.split('/')

      raise "Team member #{user_email} share field" if user_share.blank?
      raise "Team Split must add up to either 0 or 100" unless user_share.to_i.zero? || user_share.to_i == 100

      if (user = search_user(user_email))
        members << PmpMember.new(
          user_id: user.id,
          share: user_share.to_i,
          from_date: check_and_format_date(start_date),
          to_date: check_and_format_date(end_date),
          skip_callback: true
        )
      end
    end
    members
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
