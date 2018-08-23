module RoundedServices
  module Form
    class Base
      def to_hash
        hash = {}
        instance_variables.each do |var|
          next if self.send(var.to_s.delete("@")).nil?
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
        self.keywords = attributes_hash[:keywords]
        self.url = attributes_hash[:url] if attributes_hash[:url]
        self.email = attributes_hash[:email].downcase if attributes_hash[:email]
        self.title = attributes_hash[:title].downcase if attributes_hash[:title]
        self.job_type = attributes_hash[:job_type].downcase if attributes_hash[:job_type]
        self.commute_type = attributes_hash[:commute_type].downcase if attributes_hash[:commute_type]
        self.salary = attributes_hash[:salary]
        self.employer = attributes_hash[:employer]
        self.account = attributes_hash[:account]
        self.location = attributes_hash[:location]
        self.stripe_token = attributes_hash[:stripe_token] || nil
      end
    end
  end
end
