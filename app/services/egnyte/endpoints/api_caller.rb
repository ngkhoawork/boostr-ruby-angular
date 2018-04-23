class Egnyte::Endpoints::ApiCaller
  def initialize(domain)
    @domain = domain
  end

  private

  def method_missing(method, *args)
    begin
      class_by_action(method).new(@domain, *args).perform
    rescue NameError
      super
    rescue => e
      raise e
    end
  end

  def class_by_action(action)
    "Egnyte::Endpoints::#{action.to_s.camelize}".constantize
  end
end
