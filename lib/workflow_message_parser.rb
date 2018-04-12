class WorkflowMessageParser
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def get_params_array
    message.scan(/{{(.+?)}}/).flatten.map(&:strip)
  end
end
