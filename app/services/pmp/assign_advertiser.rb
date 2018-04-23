class Pmp::AssignAdvertiser

  attr_accessor :ssp_advertiser_id, :client, :company

  def initialize(opts)
    opts.each do |name, value|
      send("#{name}=", value)
    end
  end


  def bulk_assign
    return unless ssp_advertiser_id.present? && client.present?
    return unless pmps.present?
    ids = pmps.map(&:id)
    update_client
    update_advertisers
    ids
  end

  private

  def pmps
    company.pmps.no_match_advertiser(ssp_advertiser_id)
  end

  def update_client
    pmps.first.ssp_advertiser.update_attribute(:client_id, client.id)
  end

  def update_advertisers
    pmps.update_all(advertiser_id: client.id)
  end

end
