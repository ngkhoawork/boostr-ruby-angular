asana_connect_file = YAML.load_file("#{Rails.root}/config/asana_connect.yml") || {}
ASANA_CONNECT = OpenStruct.new(asana_connect_file['asana'][Rails.env])
ASANA_CONNECT.freeze
