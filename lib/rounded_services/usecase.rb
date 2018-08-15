module RoundedServices
  module Usecase
    module JobListing
      class Create
        attr_accessor :job_listing_repository,
                      :job_listing,
                      :stripe

        def initialize(job_listing_repository: Repository::JobListing.new,
                      stripe: Service::Stripe.new)
          self.job_listing_repository = job_listing_repository
          self.stripe = stripe
        end

        def execute(form:)
          job_listing = job_listing_repository.create(form: form)

          if !form.stripe_token.nil?
            stripe_charge = stripe.authorize_job_listing_charge(token: form.stripe_token, job_listing: job_listing)
            job_listing_repository.update_stripe_charge_id(reference: job_listing.reference, stripe_charge_id: stripe_charge.id)
          else
            if !form.account || !form.account.admin
              raise Error::MissingStipeTokenError
            end
          end

          self.job_listing = job_listing_repository.find_by_reference(reference: job_listing.reference)
          self
        end
      end

      class FindOne
        attr_accessor :job_listing_repository,
                      :job_listing

        def initialize(job_listing_repository: Repository::JobListing.new)
          self.job_listing_repository = job_listing_repository
        end

        def self.execute(reference:)
          usecase = new
          usecase.job_listing = usecase.job_listing_repository.find_by_reference(reference: reference)
          usecase
        end
      end

      class FindUnpublished
        attr_accessor :job_listing_repository,
                      :job_listings

        def initialize(job_listing_repository: Repository::JobListing.new)
          self.job_listing_repository = job_listing_repository
        end

        def self.execute(form:)
          raise "unauthorized access to get unpublished job listings" unless form.account.admin
          usecase = new
          usecase.job_listings = usecase.job_listing_repository.find_unpublished(page_no: form.page_no, page_size: form.page_size)
          usecase
        end
      end

      class FindPublished
        attr_accessor :job_listing_repository,
                      :job_listings

        def initialize(job_listing_repository: Repository::JobListing.new)
          self.job_listing_repository = job_listing_repository
        end

        def self.execute(form:)
          usecase = new
          usecase.job_listings = usecase.job_listing_repository.find_published(page_no: form.page_no, page_size: form.page_size)
          usecase
        end
      end

      class Publish
        attr_accessor :job_listing_repository,
                      :job_listing,
                      :stripe

        def initialize(job_listing_repository: Repository::JobListing.new,
                      stripe: Service::Stripe.new)
          self.job_listing_repository = job_listing_repository
          self.stripe = stripe
        end

        def execute(reference:, account:)
          raise RoundedServices::Error::UnauthorizedError unless account && account.admin

          job_listing = job_listing_repository.find_by_reference(reference: reference)

          if job_listing.stripe_charge_id
            stripe.capture_job_listing_charge(stripe_charge_id: job_listing.stripe_charge_id)
            job_listing_repository.mark_as_paid(reference: reference)
          end

          job_listing_repository.mark_as_published(reference: reference)
          self.job_listing = job_listing_repository.find_by_reference(reference: reference)
          self
        end
      end
    end

    module Account
      class Create
        attr_accessor :account_reposiotry,
                      :account

        def initialize(account_reposiotry: Repository::Account.new)
          self.account_reposiotry = account_reposiotry
        end

        def self.execute(email:)
          usecase = new
          usecase.account = usecase.account_reposiotry.create(email: email)
          usecase
        end
      end
    end
  end
end
