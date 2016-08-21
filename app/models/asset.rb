class Asset < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  attr_accessor :presigned_url

  def presigned_url
    obj = S3_BUCKET.object(self.asset_file_name)
    if obj.nil?
      return ""
    end
    return obj.presigned_url(:get, expires_in: 3600)
  end

  def as_json(options = {})
    super(options.merge(
              methods: [
                  :presigned_url
              ]
          )
    )
  end
end
