module RoundedServices
  module Repository
    describe JobListing do
      describe "#find_live"

      describe "#create" do
        it "creates a job listing"
      end

      describe "#update" do
        let(:attributes_hash) do
          attributes_hash = {
            title: "senior full stack developer"
          }
        end

        let(:existing_job_listing) { existing_job_listing = create(:job_listing) }

        before do
          form = RoundedServices::Form::JobListing.new(attributes_hash: attributes_hash)
          described_class.new.update(form: form, reference: existing_job_listing.reference)
          @job_listing = described_class.new.find_by_id(id: existing_job_listing.id)
        end

        it "updates dirty attributes" do
          expect(@job_listing.title).to eq(attributes_hash[:title])
        end

        it "does not update clean attributes" do
          expect(@job_listing.keywords).to eq(existing_job_listing.keywords)
          expect(@job_listing.email).to eq(existing_job_listing.email)
          expect(@job_listing.url).to eq(existing_job_listing.url)
          expect(@job_listing.job_type).to eq(existing_job_listing.job_type)
          expect(@job_listing.commute_type).to eq(existing_job_listing.commute_type)
          expect(@job_listing.salary).to eq(existing_job_listing.salary)
          expect(@job_listing.employer).to eq(existing_job_listing.employer)
          expect(@job_listing.account_id).to eq(existing_job_listing.account_id)
          expect(@job_listing.location).to eq(existing_job_listing.location)
          expect(@job_listing.stripe_charge_id).to eq(existing_job_listing.stripe_charge_id)
        end
      end

      describe "#find_by_id"

      describe "#mark_as_inactive" do
        it "sets a inactive at date on a job listing" do
          job_listing = create(:job_listing)

          JobListing.new.mark_as_inactive(reference: job_listing.reference)
          inactive_job_listing = JobListing.new.find_by_reference(reference: job_listing.reference)

          expect(inactive_job_listing.inactive_at).to be_truthy
        end
      end

      describe "#mark_as_paid" do
        it "sets a paid at date on a job listing" do
          job_listing = create(:job_listing)

          JobListing.new.mark_as_paid(reference: job_listing.reference)
          paid_job_listing = JobListing.new.find_by_reference(reference: job_listing.reference)

          expect(paid_job_listing.paid_at).to be_truthy
        end
      end

      describe "#mark_as_published" do
        it "sets a published at date on a job listing" do
          job_listing = create(:job_listing)

          JobListing.new.mark_as_published(reference: job_listing.reference)
          published_job_listing = JobListing.new.find_by_reference(reference: job_listing.reference)

          expect(published_job_listing.published_at).to be_truthy
        end
      end

      describe "#update_stripe_charge_id" do
        it "sets a stripe charge id on a job listing" do
          job_listing = create(:job_listing)

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
