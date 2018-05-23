class Hoopla::Endpoints::ApiCaller
  class << self
    private

    def method_missing(method, *args)
      begin
        class_by_action(method).new(*args).perform
      rescue NameError
        super
      rescue => e
        raise e
      end
    end

    def class_by_action(action)
      "Hoopla::Endpoints::#{action.to_s.camelize}".constantize
    end
  end
end
