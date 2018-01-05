class BaseQuery
  def initialize(options)
    @options = options.deep_symbolize_keys
  end

  private

  attr_reader :options
end
