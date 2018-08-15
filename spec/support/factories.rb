module RoundedServices
  module Factory
    class JobListing
      def self.build(attributes_hash: {})
        attributes_hash[:keywords] = "ruby"
        attributes_hash[:url] = "https://finch.blue"
        attributes_hash[:email] = "joshuaaob@gmail.com"
        attributes_hash[:title] = "senior ruby developer"
        attributes_hash[:job_type] = "permanent"
        attributes_hash[:commute_type] = "remote"
        attributes_hash[:salary] = "50k GBP"
        attributes_hash[:employer] = "finch.blue"
        attributes_hash[:account] = attributes_hash[:account]
        attributes_hash[:location] = "leeds, UK"
        attributes_hash[:stripe_token] = attributes_hash[:stripe_token]
        Form::JobListing.new(attributes_hash: attributes_hash)
      end

      def self.create(form:)
        Usecase::JobListing::Create.new.execute(form: form).job_listing
      end
    end
  end
end
