module RoundedServices
  module Form
    class Base
      def to_hash
        hash = {}
        instance_variables.each do |var|
          unless var == :@errors
            hash[var.to_s.delete("@")] = instance_variable_get(var)
          end
        end
        hash
      end
    end

    class JobListing < Base
      attr_accessor :keywords,
                    :url,
                    :email,
                    :title,
                    :job_type,
                    :commute_type,
                    :salary,
                    :employer,
                    :account,
                    :location,
                    :stripe_token

      def initialize(attributes_hash:)
        self.keywords = attributes_hash[:keywords].downcase
        self.url = attributes_hash[:url].downcase
        self.email = attributes_hash[:email].downcase
        self.title = attributes_hash[:title].downcase
        self.job_type = attributes_hash[:job_type].downcase
        self.commute_type = attributes_hash[:commute_type].downcase
        self.salary = attributes_hash[:salary].downcase
        self.employer = attributes_hash[:employer]
        self.account = attributes_hash[:account]
        self.location = attributes_hash[:location]
        self.stripe_token = attributes_hash[:stripe_token] || nil
      end
    end
  end
end
