require 'roar/decorator'
require 'roar/json'

class API::Collection < Roar::Decorator
  include Roar::JSON
end
