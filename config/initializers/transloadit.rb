template = YAML.load_file("#{Rails.root}/config/transloadit.yml") || {}
TRANSLOADIT_TEMPLATES = template['transloadit'][ENV['S3_BUCKET_NAME']]
