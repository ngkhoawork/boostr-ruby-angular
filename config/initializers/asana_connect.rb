asana_connect_file = YAML.load_file("#{Rails.root}/config/asana_connect.yml") || {}
ASANA_CONNECT = OpenStruct.new(asana_connect_file['asana'][ENV['ASANA_CONNECT_ENV']])
ASANA_CONNECT.freeze
