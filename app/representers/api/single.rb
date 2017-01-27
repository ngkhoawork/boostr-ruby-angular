require 'roar/decorator'
require 'roar/json'

class API::Single < Roar::Decorator
  include Roar::JSON
  include Roar::Hypermedia

  class << self
    def properties(*props)
      props.each { |prop| property prop }
    end
  end
end
