module CompanyMappings
  extend ActiveSupport::Concern

  def buzzfeed?
    id.eql?(44)
  end
end
