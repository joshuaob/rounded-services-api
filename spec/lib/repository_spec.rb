module RoundedServices
  module Repository
    describe JobListing do
      describe "#create" do
        it "creates a job listing"
      end

      describe "#update" do
        it "updates a job listing"
      end

      describe "#mark_as_paid" do
        it "sets a paid at date on a job listing" do
          account = Repository::Account.new.create(email: "joshuaaob@gmail.com")
          form = Factory::JobListing.build(attributes_hash: {account: account})
          job_listing = Factory::JobListing.create(form: form)

          JobListing.new.mark_as_paid(reference: job_listing.reference)
          paid_job_listing = JobListing.new.find_by_reference(reference: job_listing.reference)

          expect(paid_job_listing.paid_at).to be_truthy
        end
      end

      describe "#mark_as_published" do
        it "sets a published at date on a job listing" do
          account = Repository::Account.new.create(email: "joshuaaob@gmail.com")
          form = Factory::JobListing.build(attributes_hash: {account: account})
          job_listing = Factory::JobListing.create(form: form)

          JobListing.new.mark_as_published(reference: job_listing.reference)
          published_job_listing = JobListing.new.find_by_reference(reference: job_listing.reference)

          expect(published_job_listing.published_at).to be_truthy
        end
      end

      describe "#update_stripe_charge_id" do
        it "sets a stripe charge id on a job listing" do
          account = Repository::Account.new.create(email: "joshuaaob@gmail.com")
          form = Factory::JobListing.build(attributes_hash: {account: account})
          job_listing = Factory::JobListing.create(form: form)

          JobListing.new.update_stripe_charge_id(reference: job_listing.reference, stripe_charge_id: "123")
          paid_job_listing = JobListing.new.find_by_reference(reference: job_listing.reference)

          expect(paid_job_listing.stripe_charge_id).to eq("123")
        end
      end

      describe "#where_not_refunded" do
        it "returns rows where refunded is false"
      end

      describe "#where_not_expired" do
        it "returns rows that were published within 30 days"
      end

      describe "#where_not_paid" do
        it "returns rows where paid is false"
      end

      describe "#where_not_published" do
        it "returns rows where published is false"
      end

      describe "#where_published" do
        it "returns rows where published is true"
      end

      describe "#where_paid" do
        it "returns rows where paid is true"
      end
    end
  end
end
