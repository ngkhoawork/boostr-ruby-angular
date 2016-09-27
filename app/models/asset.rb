class Asset < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  attr_accessor :presigned_url

  ONE_HOUR = 60 * 60

  def presigned_url
    # TODO Check other cases of URL transformation
    obj = S3_BUCKET.object(self.asset_file_name.gsub(" ", "-"))
    if obj.nil?
      return ""
    end
    return obj.presigned_url(:get, expires_in: ONE_HOUR)
  end

  def as_json(options = {})
    super(options.merge(
              methods: [
                  :presigned_url
              ]
          )
    )
  end

  def delete_from_s3
    obj = S3_BUCKET.object(self.asset_file_name)
    obj.delete if obj
  end
end
