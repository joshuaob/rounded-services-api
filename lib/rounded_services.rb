require 'sinatra/base'
require "sinatra/namespace"
require 'pg'
require 'sequel'
require 'raven'
require 'jsonapi-serializers'
require 'jwt'
require 'net/http'
require 'uri'
require 'stripe'

if ["development", "test"].include?(::ENV["RACK_ENV"])
  require "pry"
end

require 'dotenv'
if ::ENV["RACK_ENV"] == "test"
  Dotenv.load('test.env')
else
  Dotenv.load('.env')
end

require_relative 'rounded_services/config'

Raven.configure do |config|
  config.dsn = RoundedServices::Config.instance.sentry_dsn
end

def capture_exception(e)
  Raven.capture_exception(e)
end

require_relative 'rounded_services/entity'
require_relative 'rounded_services/repository'
require_relative 'rounded_services/form'
require_relative 'rounded_services/service'
require_relative 'rounded_services/usecase'


module RoundedServices
  class JsonapiError
    attr_accessor :title, :id, :links, :code, :status, :detail, :source, :meta

    def initialize(title: nil, id:  nil, links:  nil, code:  nil, status: nil, detail: nil, source: nil, meta: nil)
      self.id = id
      self.title = title
      self.links = links
      self.code = code
      self.status = status
      self.detail = detail
      self.source = source
      self.meta = meta
      super()
    end

    def to_hash
      hash = {}
      instance_variables.each do |var|
        unless instance_variable_get(var).nil?
          hash[var.to_s.delete("@")] = instance_variable_get(var)
        end
      end
      hash
    end
  end

  class JWT
    def self.verify(token)
      ::JWT.decode(token, nil,
                 true,
                 algorithm: ENV['AUTH0_JWKS_ALG'],
                 iss: ENV['AUTH0_JWKS_ISS'],
                 verify_iss: true,
                 aud: ENV['AUTH0_JWKS_AUD'],
                 verify_aud: true) do |header|
        jwks_hash[header['kid']]
      end
    end

    def self.jwks_hash
      jwks_raw = Net::HTTP.get URI("#{ENV['AUTH0_JWKS_ISS']}.well-known/jwks.json")
      jwks_keys = Array(JSON.parse(jwks_raw)['keys'])
      Hash[
        jwks_keys
        .map do |k|
          [
            k['kid'],
            OpenSSL::X509::Certificate.new(
              Base64.decode64(k['x5c'].first)
            ).public_key
          ]
        end
      ]
    end
  end

  module SensitiveData
    def self.encrypt(payload:)
      JWE.encrypt(payload.to_json, private_key.public_key)
    end

    def self.decrypt(token:)
      JSON.parse(JWE.decrypt(token, private_key))
    end

    private

    def self.private_key
      private_key_pathname = Pathname.new(::ENV["PITCH_IT_PRIVATE_KEY_PATH"])
      OpenSSL::PKey::RSA.new(File.read(private_key_pathname))
    end
  end

  module Error
    class MissingStipeTokenError < StandardError ;end
    class UnauthorizedError < StandardError ;end
  end
end

require_relative 'rounded_services/api/v1'
