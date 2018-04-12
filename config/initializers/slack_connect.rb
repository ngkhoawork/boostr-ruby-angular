slack_connect_file = YAML.load_file("#{Rails.root}/config/slack_connect.yml") || {}
slack_connect_env = ENV['SLACK_CONNECT_ENV'] || 'development'
SLACK_CONNECT = OpenStruct.new(slack_connect_file['slack'][slack_connect_env])
SLACK_CONNECT.freeze
