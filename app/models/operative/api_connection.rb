# module ExternalApi
#   class Connection
#     class << self
#       def client
#         @client ||= begin
        
#           params = {
#             endpoint: @endpoint.call,
#             namespace: @namespace,
#             headers: {},
#             logger: logger
#           }

#           Savon.client(params)          
#         end
#       end

#       def logger
#         Config.logger
#       end

#       def endpoint(&block)
#         @endpoint = block
#       end

#       def namespace(uri)
#         @namespace = uri
#       end

#       def company_key=(token)
#         @@company_key = token
#       end

#       def company_key
#         @@company_key = Config.company_key
#       end

#       def auth_token
#         @@auth_token = Config.auth_token
#       end

      
#     end
#   end
# end
