module RoundedServices
  module Service
    class Stripe
      def initialize(config: RoundedServices::Config.instance)
        ::Stripe.api_key = config.stripe_api_key
      end

      def authorize_job_listing_charge(token:, job_listing:)
        ::Stripe::Charge.create(
          :amount => 25000,
          :currency => "gbp",
          :source => token,
          :description => "Rounded Services Job Listing (#{jobListing.reference}) £250 - Charge for #{job_listing.email}",
          :capture => false,
          :metadata => {
            job_listing_reference: job_listing.reference
          }
        )
      end

      def capture_job_listing_charge(stripe_charge_id:)
        ch = ::Stripe::Charge.retrieve(stripe_charge_id)
        ch.capture
      end
    end
  end
end
