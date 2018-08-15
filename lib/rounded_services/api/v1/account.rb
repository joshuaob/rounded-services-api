require_relative '../serializer/v1/account'

module RoundedServices
  module API
    class V1 < Sinatra::Base
      def account_serializer
        result = "RoundedServices::API::Serializer::V#{requested_api_version}::Account"
        result.constantize
      rescue NameError => e
        api_errors << JsonapiError.build_invalid_api_version_error
        halt 500, JSONAPI::Serializer.serialize_errors(api_errors).to_json
      end

      namespace '/v1' do
        options '/accounts' do
        end

        get '/accounts' do
          begin
            account = find_or_create_account
            body account_serializer.serialize(account).to_json

          rescue Exception => e
            capture_exception(e)
            halt 422
          end
        end
      end
    end
  end
end
