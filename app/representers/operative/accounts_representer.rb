require 'representable/xml'

class Operative::AccountsRepresenter < Representable::Decorator
  include Representable::XML

  self.representation_wrap = :accounts

  property :agency_account, exec_context: :decorator, decorator: Operative::AgencyRepresenter
  property :advertiser_account, exec_context: :decorator, decorator: Operative::AdvertiserRepresenter

  def advertiser_account
    represented
  end

  def agency_account
    represented
  end
end
