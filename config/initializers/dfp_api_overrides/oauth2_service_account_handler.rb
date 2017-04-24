require 'dfp_api'

module AdsCommon
  module Auth

    class OAuth2ServiceAccountHandler

      private

      def validate_credentials(credentials)
        if @scopes.empty?
          raise AdsCommon::Errors::AuthError, 'Scope is not specified.'
        end

        if credentials.nil?
          raise AdsCommon::Errors::AuthError, 'No credentials supplied.'
        end

        if credentials[:oauth2_key].nil? && credentials[:oauth2_keyfile].nil? && credentials[:oauth2_json_string].nil?
          raise AdsCommon::Errors::AuthError, 'Either key or key file must ' +
              'be provided for OAuth2 service account.'
        end

        if credentials[:oauth2_key] && credentials[:oauth2_keyfile] && credentials[:oauth2_json_string]
        raise AdsCommon::Errors::AuthError, 'Both service account key and ' +
            'key file provided, only one can be used.'
        end

        if credentials[:oauth2_keyfile]
          file_name = credentials[:oauth2_keyfile]
          if File.file?(file_name)
            unless file_name.end_with?('.json')
              raise AdsCommon::Errors::AuthError,
                    "Key file '%s' must be a .json file." % file_name
            end
          else
            raise AdsCommon::Errors::AuthError,
                  "Key file '%s' does not exist or not a file." % file_name
          end
        end

        if credentials[:oauth2_key] &&
            !credentials[:oauth2_key].kind_of?(OpenSSL::PKey::RSA)
          raise AdsCommon::Errors::AuthError, 'OAuth2 service account key ' +
              'provided must be of type OpenSSL::PKey::RSA.'
        end
      end


      def load_oauth2_service_account_credentials(credentials)
        return credentials unless credentials.include?(:oauth2_keyfile) || credentials[:oauth2_json_string]
        json_content = if credentials[:oauth2_keyfile]
                         File.read(credentials[:oauth2_keyfile])
                       else
                         credentials[:oauth2_json_string]
                       end
        parsed_json = JSON.parse(json_content, :symbolize_names => true)
        key = OpenSSL::PKey::RSA.new(parsed_json[:private_key])
        issuer = parsed_json[:client_email]
        result = credentials.merge({:oauth2_key => key})
        result[:oauth2_issuer] = issuer unless issuer.nil?
        result.delete(:oauth2_keyfile) if credentials[:oauth2_keyfile]
        return result
      end
    end
  end
end