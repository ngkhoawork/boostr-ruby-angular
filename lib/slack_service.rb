class SlackService
  def initialize(token)
    @token = token
  end

  def post_message(channel_name, message, options = {})
    channel = channel_present?(channel_name) ? channel_name : create_channel(channel_name).dig(:channel, :name)

    client.chat_postMessage(channel: "##{channel}",
                            text: CGI::unescapeHTML(message.to_s),
                            parse: 'full',
                            attachments: [options.fetch(:attachment)])
  end

  def list_of_channels
    client.channels_list.fetch(:channels)
  end

  def create_channel(name)
    client.channels_create(name: name)
  end

  private

  attr_reader :token

  def channel_present?(channel_name)
    channel_names.include?(channel_name)
  end

  def channel_names
    list_of_channels.map(&:name)
  end

  def client
    @_client ||= Slack::Web::Client.new(token: token)
  end
end

