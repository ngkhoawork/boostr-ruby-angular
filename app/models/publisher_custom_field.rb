class PublisherCustomField < ActiveRecord::Base
  belongs_to :company, required: true
  belongs_to :publisher, required: true
end
