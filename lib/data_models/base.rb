class DataModels::Base
  class << self
    def get_mappings(object)
      parsed_json.dig(object.downcase.to_sym, :mappings)
    end

    def parsed_json
      json = JSON.parse config_json_file, object_class: Hash
      json.deep_symbolize_keys
    end

    def config_json_file
      File.read(config_json_path)
    end

    def config_json_path
      ''
    end
  end
end
