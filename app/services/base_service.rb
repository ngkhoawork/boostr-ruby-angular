class BaseService
  def initialize(opts = {})
    opts.each do |name, value|
      instance_variable_set("@#{name}", value)
      self.class.send(:attr_reader, name)
    end
  end

  def search_ssp type
    Ssp.find_by(name: type)&.id
  end
end