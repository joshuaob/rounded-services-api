module RoundedServices
  module API
    class ErrorHandler

      attr_accessor :errors

      def initialize(errors:)
        self.errors = errors
        super()
      end

      def handle_entity_validation_error(entity_validation_error)
        entity_validation_error.entity.errors.each do |e|
          jsonapi_error = JsonapiError.new
          jsonapi_error.title = e.title.capitalize
          jsonapi_error.status = 422
          self.errors << jsonapi_error.to_hash
        end
        self
      end

      def handle_entity_not_found_error(e)
        jsonapi_error = JsonapiError.new
        jsonapi_error.title = "Invitation not found, please review invite link and try again."
        jsonapi_error.status = 404
        self.errors << jsonapi_error.to_hash
        self
      end

      def handle_expired_invitation_error(e)
        jsonapi_error = JsonapiError.new
        jsonapi_error.title = "Invitation expired, please request a new invitation."
        jsonapi_error.status = 400
        self.errors << jsonapi_error.to_hash
        self
      end

      def handle_entity_duplicate_error(e)
        jsonapi_error = JsonapiError.new
        jsonapi_error.title = "That email has already been invited, check your email for an invitation link or contact us."
        jsonapi_error.status = 422
        self.errors << jsonapi_error.to_hash
        self
      end

      def handle_duplicate_email_error(e)
        jsonapi_error = JsonapiError.new
        jsonapi_error.title = "That email already exists, try to login instead."
        jsonapi_error.status = 422
        self.errors << jsonapi_error.to_hash
        self
      end

      def handle_api_authentication_error(e)
        jsonapi_error = JsonapiError.new
        jsonapi_error.title = e.title
        jsonapi_error.status = 401
        self.errors << jsonapi_error.to_hash
        self
      end

      def handle_jwt_decode_error(title:, detail:)
        jsonapi_error = JsonapiError.new
        jsonapi_error.title = title
        jsonapi_error.detail = detail
        jsonapi_error.status = 401
        self.errors << jsonapi_error.to_hash
        self
      end

      def handle_jwt_expiry_error(title:, detail:)
        jsonapi_error = JsonapiError.new
        jsonapi_error.title = title
        jsonapi_error.detail = detail
        jsonapi_error.status = 401
        self.errors << jsonapi_error.to_hash
        self
      end

      def handle_jwt_verification_error(title:, detail:)
        jsonapi_error = JsonapiError.new
        jsonapi_error.title = title
        jsonapi_error.detail = detail
        jsonapi_error.status = 401
        self.errors << jsonapi_error.to_hash
        self
      end

      def handle_blank_request_body_api_error(e)
        jsonapi_error = JsonapiError.new
        jsonapi_error.title = e.title
        jsonapi_error.detail = e.title
        jsonapi_error.status = 422
        self.errors << jsonapi_error.to_hash
        self
      end

      def handle_json_parse_error(e)
        jsonapi_error = JsonapiError.new
        jsonapi_error.title = "Invalid JSON in request body."
        jsonapi_error.detail = e.message
        jsonapi_error.status = 422
        self.errors << jsonapi_error.to_hash
        self
      end

      def handle_invalid_api_version_error(version)
        jsonapi_error = JsonapiError.new
        jsonapi_error.title = "Something went wrong, please try again or contact us."
        jsonapi_error.detail = "Unknown API Version #{version}."
        jsonapi_error.status = 400
        self.errors << jsonapi_error.to_hash
        self
      end

      def handle_used_demo_invitation_error(e)
        jsonapi_error = JsonapiError.new
        jsonapi_error.title = "Invitation has already been accepted. Please request a new one."
        jsonapi_error.status = 422
        self.errors << jsonapi_error.to_hash
        self
      end

      def handle_expired_demo_invitation_error(e)
        jsonapi_error = JsonapiError.new
        jsonapi_error.title = "Invitation has expired. Please request a new one."
        jsonapi_error.status = 422
        self.errors << jsonapi_error.to_hash
        self
      end

      def handle_login_link_expired_error(e)
        jsonapi_error = JsonapiError.new
        jsonapi_error.title = "token expired"
        jsonapi_error.detail = "token expired"
        jsonapi_error.status = 401
        self.errors << jsonapi_error.to_hash
        self
      end

      def handle_login_link_not_found_error(e)
        jsonapi_error = JsonapiError.new
        jsonapi_error.title = "login link not found"
        jsonapi_error.status = 404
        self.errors << jsonapi_error.to_hash
        self
      end

      def handle_recruiter_profile_not_found_error(e)
        jsonapi_error = JsonapiError.new
        jsonapi_error.title = "recruiter profile not found"
        jsonapi_error.status = 404
        self.errors << jsonapi_error.to_hash
        self
      end
    end

    # module Error
    #   class Base < StandardError
    #     attr_accessor :title, :detail
    #
    #     def initialize(title)
    #        super(title)
    #     end
    #   end
    #
    #   class BlankRequestBody < API::Error::Base
    #     def initialize(title:, detail: nil)
    #       self.title = title
    #       self.detail = detail
    #       super(title)
    #     end
    #   end
    # end

    class V1 < Sinatra::Base

      configure do
        if ["development", "test"].include?(RoundedServices::Config.instance.env)
          enable :logging
          file = File.new("./log/puma.#{RoundedServices::Config.instance.env}.log", 'a+')
          file.sync = true
          use Rack::CommonLogger, file
        else
          use Rack::CommonLogger
        end
        use Raven::Rack
      end

      before do
        # activate_maintenance_mode
        @config = RoundedServices::Config.instance

        # setup CORS headers
        headers['Access-Control-Allow-Methods'] = "OPTIONS, GET, POST, DELETE, PATCH, PUT"
        headers['Access-Control-Allow-Headers'] = "Content-Type, Accept-Version, Authorization"
        headers['Access-Control-Allow-Credentials'] = "true"

        if ["development", "staging", "production"].include?(@config.env)
          allowed_origin = get_allowed_origin(@config.env, request.env["HTTP_ORIGIN"])
          headers['Access-Control-Allow-Origin'] = allowed_origin if allowed_origin
        end

        # verify media type
        halt 415 if req_includes_unsupported_media_type?
        halt 415 if req_includes_media_type_params?

        # build jsonapi error handler
        @jsonapi_errors = []
        @api_error_handler = ErrorHandler.new(errors: @jsonapi_errors)
        @cookie_jar = {}

        # build cookie jar
        http_cookie = env["HTTP_COOKIE"]
        unless http_cookie.nil? || http_cookie.empty?
          http_cookie.split(";").each do |i|
            cookie = i.split("=")
            k = cookie[0].gsub(" ","")
            v = cookie[1]
            @cookie_jar[k] = v
          end
        end
      end

      after do
        headers "Content-Type" => "application/vnd.api+json"
      end

      register Sinatra::Namespace

      def activate_maintenance_mode
        halt 503, "service unavailable"
      end

      def requested_api_version
        request.env["HTTP_ACCEPT_VERSION"]
      end

      def development_origins
        [
          'http://localhost:4211'
        ]
      end

      def staging_origins
        [
          'https://staging.web.rounded.services'
        ]
      end

      def production_origins
        [
          'https://rounded.services',
          'https://www.rounded.services'
        ]
      end

      def get_allowed_origin(env, request_origin)
        if env == "development"
          return request_origin if development_origins.include?(request_origin)
        end

        if env == "staging"
          return request_origin if staging_origins.include?(request_origin)
        end

        if env == "production"
          return request_origin if production_origins.include?(request_origin)
        end
      end

      # convert and return attributes hash keys to symbols
      def attributes_hash
        request.body.rewind
        request_body = JSON.parse(request.body.read)
        if request_body.keys.include?("data")
          if request_body["data"].keys.include?("attributes")
            return Hash[request_body["data"]["attributes"].map{|(k,v)| [k.to_sym,v]}]
          else
            return nil
          end
        end
      end

      # jsonapi spec says the server must return a 415
      # if the request contains a media type with any parameters
      def req_includes_media_type_params?
        content_type = request.env["CONTENT_TYPE"]
        return unless content_type
        content_type = content_type.split(";")
        media_type = content_type[0]
        media_type_params = content_type.drop(1)
        !req_includes_unsupported_media_type? && media_type_params.size > 0
      end

      # return 415 status code for request with unsupported media type
      def req_includes_unsupported_media_type?
        content_type = request.env["CONTENT_TYPE"]
        return unless content_type
        content_type = content_type.split(";")
        media_type = content_type[0]
        media_type != "application/vnd.api+json"
      end

      def find_or_create_account
        payload = authenticate
        RoundedServices::Usecase::Account::Create.execute(email: payload[0]["email"]).account
      end

      # TODO: test this 
      def find_account
        authorization = env["HTTP_AUTHORIZATION"]
        jwt = authorization.split[-1]
        return nil unless jwt
        payload = RoundedServices::JWT.verify(jwt)
        RoundedServices::Usecase::Account::FindOne.execute(email: payload[0]["email"]).account
      end

      def authenticate
        begin
          authorization = env["HTTP_AUTHORIZATION"]
          jwt = authorization.split[-1]
          raise "authentication error, authorization header is not present" unless jwt
          @auth_payload, @auth_header = RoundedServices::JWT.verify(jwt)

        rescue Exception => e
          capture_exception(e)
          halt 401
        end
      end
    end
  end
end
