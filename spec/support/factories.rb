module RoundedServices
  module Factory
    class JobListing
      def self.build(account: nil, stripe_token: nil, attributes: {})
        job_listing = Entity::JobListing.new
        job_listing.keywords = attributes[:keywords] || "ruby, rails, emberjs, aws, linux"
        job_listing.url = attributes[:url] || "https://rounded.services"
        job_listing.email = attributes[:email] || "hello@rounded.services"
        job_listing.title = attributes[:title] || "senior ruby developer"
        job_listing.job_type = attributes[:job_type] || "permanent"
        job_listing.commute_type = attributes[:commute_type] || "remote"
        job_listing.salary = attributes[:salary] || "50k GBP"
        job_listing.employer = attributes[:employer] || "Rounded Services"
        job_listing.account_id = account.id if account
        job_listing.location = attributes[:location] || "leeds, UK"
        # job_listing.stripe_charge_id = attributes_hash[:stripe_charge_id] || "tok_visa_charge_id" unless account.nil?
        job_listing
      end
      # def self.build(attributes_hash: {})
      #   attributes_hash[:keywords] = "ruby"
      #   attributes_hash[:url] = "https://finch.blue"
      #   attributes_hash[:email] = "joshuaaob@gmail.com"
      #   attributes_hash[:title] = "senior ruby developer"
      #   attributes_hash[:job_type] = "permanent"
      #   attributes_hash[:commute_type] = "remote"
      #   attributes_hash[:salary] = "50k GBP"
      #   attributes_hash[:employer] = "finch.blue"
      #   attributes_hash[:account] = attributes_hash[:account]
      #   attributes_hash[:location] = "leeds, UK"
      #   attributes_hash[:stripe_token] = attributes_hash[:stripe_token]
      #   Form::JobListing.new(attributes_hash: attributes_hash)
      # end
      #
      # def self.create(form:)
      #   Usecase::JobListing::Create.new.execute(form: form).job_listing
      # end
    end
  end
end
