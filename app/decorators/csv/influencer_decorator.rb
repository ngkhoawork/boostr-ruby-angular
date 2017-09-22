class Csv::InfluencerDecorator
  def initialize(influencer)
    @influencer = influencer
  end

  def id
    influencer.id
  end

  def name
    influencer.name
  end

  def network
    influencer.network_name
  end

  def agreement_type
    influencer.agreement_fee_type
  end

  def agreement_fee
    influencer.agreement_amount
  end

  def email
    influencer.email
  end

  def phone
    influencer.phone
  end

  def street
    (influencer.street1 || "") + " " + (influencer.street2 || "")
  end

  def city
    influencer.city
  end

  def state
    influencer.state
  end

  def country
    influencer.country
  end

  def postal_code
    influencer.zip
  end

  def active
    influencer.active? ? "Active" : "Inactive"
  end


  private

  attr_reader :influencer
end
