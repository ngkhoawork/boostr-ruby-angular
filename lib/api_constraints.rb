class ApiConstraints
  def initialize(options)
    @version = options[:version]
  end

  def matches?(req)
    req.headers['Accept']
      &.include?("application/vnd.boostr.v#{@version}")
  end
end
