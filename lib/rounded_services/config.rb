module RoundedServices
  class Singleton
    private_class_method(:new, :dup, :clone)

    def self.instance
      @instance ||= new
    end
  end

  class Config < RoundedServices::Singleton

    attr_accessor :env,
                  :db_host,
                  :db_user,
                  :db_password,
                  :db_name,
                  :sentry_dsn,
                  :hmac_secret,
                  :sib_api_key,
                  :stripe_api_key

    def initialize
      self.env = ::ENV['RACK_ENV']
      self.db_host = ::ENV['DB_HOST']
      self.db_user = ::ENV['DB_USER']
      self.db_password = ::ENV['DB_PASSWORD']
      self.db_name = ::ENV['DB_NAME']
      self.sentry_dsn = ::ENV['SENTRY_DSN']
      self.hmac_secret = ::ENV['HMAC_SECRET']
      self.sib_api_key = ::ENV['SIB_API_KEY']
      self.stripe_api_key = ::ENV['STRIPE_API_KEY']
      super()
    end
  end

  class Database < RoundedServices::Singleton

    attr_accessor :db

    def initialize
      config = RoundedServices::Config.instance
      self.db = Sequel.postgres(host: config.db_host, user: config.db_user, password: config.db_password, database: config.db_name)
      self.db.extension :pg_json
      self.db.extension :pagination
      Sequel.extension :pg_json_ops
      super()
    end
  end
end
