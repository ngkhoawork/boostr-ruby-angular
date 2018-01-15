egnyte_configs_file = File.join(Rails.root, 'config', 'egnyte.yml')

raise 'egnyte.yml file is not present' unless File.exists?(egnyte_configs_file)

env = ENV['RAILS_ENV'] || 'development'

YAML.load_file(egnyte_configs_file)[env].each do |key, value|
  ENV["egnyte_#{key}"] = value
end
