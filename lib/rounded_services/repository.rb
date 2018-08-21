module RoundedServices
  module Repository
    class Base
      attr_accessor :dataset

      def initialize(dataset:)
        self.dataset = RoundedServices::Database.instance.db[dataset.to_sym]
        super()
      end

      def generate_reference
        reference = loop do
          random_reference = SecureRandom.urlsafe_base64(nil, false)
          break random_reference unless reference_exists?(reference: random_reference)
        end
      end

      def reference_exists?(reference:)
        dataset.where(reference: reference).count > 0
      end
    end

    class JobListing < Base
      def initialize(dataset: "job_listings")
        super(dataset: dataset)
      end

      def create(form:)
        job_listing = Entity::JobListing.new(attributes: form.to_hash.except("account", "stripe_token"))
        job_listing.account_id = form.account.id if form.account
        save(job_listing: job_listing)
      end

      def find_by_reference(reference:)
        attributes = dataset.where(:reference => reference).first
        RoundedServices::Entity::JobListing.new(attributes: attributes) if attributes
      end

      def find_by_id(id:)
        attributes = dataset.where(:id => id).first
        RoundedServices::Entity::JobListing.new(attributes: attributes) if attributes
      end

      def find_unpublished(page_no:, page_size:)
        result = []
        dataset.where(:published_at => nil).order(Sequel.desc(:created_at)).paginate(page_no, page_size).each do |attributes|
          result << Entity::JobListing.new(attributes: attributes) if attributes
        end
        result
      end

      def find_published(page_no:, page_size:)
        result = []
        dataset.exclude(:published_at => nil).order(Sequel.desc(:published_at)).paginate(page_no, page_size).each do |attributes|
          result << Entity::JobListing.new(attributes: attributes) if attributes
        end
        result
      end

      def mark_as_published(reference:)
        dataset.where(:reference => reference).update(:published_at => Time.now.utc)
      end

      def mark_as_paid(reference:)
        dataset.where(:reference => reference).update(:paid_at => Time.now.utc)
      end

      def update_stripe_charge_id(reference:, stripe_charge_id:)
        dataset.where(:reference => reference).update(:stripe_charge_id => stripe_charge_id)
      end

      def save(job_listing:)
        job_listing.reference = generate_reference
        job_listing.created_at = Time.now.utc

        unless job_listing.valid?
          raise "invalid entity - job_listing"
        end

        job_listing.id = dataset.insert(job_listing.to_row)

        job_listing
      end

      def update(form:, reference:)
        dataset.where(:reference => reference).update(form.to_hash)
      end

      def mark_as_inactive(reference:)
        dataset.where(:reference => reference).update(:inactive_at => Time.now.utc)
      end
    end

    class Account < Base
      def initialize(dataset: "accounts")
        super(dataset: dataset)
      end

      def create(email:)
        existing_account = find_by_email(email: email)
        return existing_account if existing_account

        account = RoundedServices::Entity::Account.new
        account.email = email

        save(account: account)
      end

      def save(account:)
        account.reference = generate_reference
        account.created_at = Time.now.utc

        unless account.valid?
          raise "invalid entity - account"
        end

        account.id = dataset.insert(account.to_row)

        account
      end

      def find_by_email(email:)
        attributes = dataset.where(:email => email).first
        RoundedServices::Entity::Account.new(attributes: attributes) if attributes
      end

      def find_by_id(id:)
        attributes = dataset.where(:id => id).first
        RoundedServices::Entity::Account.new(attributes: attributes) if attributes
      end
    end
  end
end
