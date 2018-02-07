class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @dataexport = options[:dataexport]
  end

  def matches?(req)
    return true if @dataexport && req.headers['Accept'].include?("application/vnd.boostr.dataexport")

    req.headers['Accept']
      &.include?("application/vnd.boostr.v#{@version}")
  end
end
