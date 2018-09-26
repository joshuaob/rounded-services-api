module RoundedServices
  module Entity
    class Base

      VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

      attr_accessor :created_at,
                    :updated_at,
                    :reference,
                    :id,
                    :errors

      def initialize(attributes: {})
        attributes.each do |k,v|
         instance_variable_set("@#{k}", v) unless v.nil?
        end
        self.errors = []
      end

      def to_row
        hash = {}
        instance_variables.each do |var|
          unless var == :@errors
            hash[var.to_s.delete("@")] = instance_variable_get(var)
          end
        end
        hash
      end
    end

    class ValidationError
      attr_accessor :title,
                    :detail

      def initialize(title:, detail: nil)
        self.title = title
        self.detail = detail
        super()
      end
    end

    class JobListing < Base
      attr_accessor :keywords,
                    :email,
                    :title,
                    :job_type,
                    :commute_type,
                    :salary,
                    :url,
                    :employer,
                    :published,
                    :account_id,
                    :location,
                    :published_at,
                    :paid_at,
                    :stripe_charge_id,
                    :inactive_at,
                    :featured_at

      def valid?
        if email.nil? || VALID_EMAIL_REGEX.match(email).nil?
          self.errors << RoundedServices::Entity::ValidationError.new(title: "that did not work, a valid email is required.")
        end

        errors.size == 0
      end

      def published?
        !published_at.nil?
      end

      def paid?
        !paid_at.nil?
      end

      def active?
        !inactive_at.nil?
      end
    end

    class Account < Base
      attr_accessor :email,
                    :admin

      def valid?
        if email.nil? || VALID_EMAIL_REGEX.match(email).nil?
          self.errors << RoundedServices::Entity::ValidationError.new(title: "that did not work, a valid email is required.")
        end

        errors.size == 0
      end
    end
  end
end
