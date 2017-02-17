require 'representable/xml'

class Operative::AccountsRepresenter < Representable::Decorator
  include Representable::XML

  self.representation_wrap = :accounts

  property :advertiser, decorator: Operative::AdvertiserRepresenter
  property :agency, decorator: Operative::AgencyRepresenter
end
