def symbolize_keys(hash)
  Hash[hash.map{|(k,v)| [k.to_sym,v]}]
end

module RoundedServices
  module Usecase
    module JobListing
      describe Create do
        context "when admin" do
          let(:stripe) { instance_double(Service::Stripe, authorize_job_listing_charge: OpenStruct.new(id: "123")) }
          let(:usecase) do
            account = create(:account, admin: true)
            attributes_hash = symbolize_keys(build(:job_listing).to_row)
            attributes_hash.merge!(account: account)
            form = RoundedServices::Form::JobListing.new(attributes_hash: attributes_hash)
            Create.new(stripe: stripe).execute(form: form)
          end

          it "creates a job listing" do
            expect(usecase.job_listing.id).to be_truthy
          end

          it "does not trigger stripe to authorize payment" do
            expect(stripe).to_not have_received(:authorize_job_listing_charge)
          end
        end

        context "when guest" do
          context "when stripe token is not present" do
            it "raises missing stripe token error" do
              attributes_hash = symbolize_keys(build(:job_listing).to_row)
              form = RoundedServices::Form::JobListing.new(attributes_hash: attributes_hash)
              expect{Create.new.execute(form: form)}.to raise_error(RoundedServices::Error::MissingStipeTokenError)
            end
          end

          context "when stripe token is present" do
            let(:stripe) { instance_double(Service::Stripe, authorize_job_listing_charge: OpenStruct.new(id: "123")) }
            let(:form) do
              attributes_hash = symbolize_keys(build(:job_listing).to_row)
              attributes_hash.merge!(stripe_token: "tok_visa")
              RoundedServices::Form::JobListing.new(attributes_hash: attributes_hash)
            end

            before do
              @usecase = Create.new(stripe: stripe).execute(form: form)
            end

            it "creates a job listing" do
              expect(@usecase.job_listing.id).to be_truthy
            end

            it "triggers stripe to authorize the charge" do
              expect(stripe).to have_received(:authorize_job_listing_charge)
              # .with(token: "tok_visa", job_listing: @usecase.job_listing)
            end

            it "captures the stripe charge id" do
              expect(@usecase.job_listing.stripe_charge_id).to be_truthy
            end
          end
        end
      end

      describe Publish do
        context "when admin" do
          let(:stripe) { instance_double(Service::Stripe, capture_job_listing_charge: OpenStruct.new(id: "123")) }

          context "when publishing own job listing" do
            let(:account) { create(:account, admin: true) }
            let(:job_listing) do
              create(:job_listing, account_id: account.id, email: account.email)
            end

            before do
              @usecase = Publish.new(stripe: stripe).execute(reference: job_listing.reference, account: account)
            end

            it "does not trigger stripe to capture a payment" do
              expect(stripe).to_not have_received(:capture_job_listing_charge)
            end

            it "does not set the paid date on a job listing" do
              expect(@usecase.job_listing.paid_at).to be_falsey
            end

            it "sets the published date on a job listing" do
              expect(@usecase.job_listing.published_at).to be_truthy
            end

            xit "notifies the job listing owner"
          end

          context "when publishing job listings by others" do
            let(:admin_account) { create(:account, admin: true) }
            # let(:non_admin_account) { Repository::Account.new.create(email: "user@rounded.services") }
            let(:job_listing) do
              create(:job_listing, stripe_charge_id: "123" )
              # Factory::JobListing.create(form: Factory::JobListing.build(attributes_hash: { account: non_admin_account, stripe_token: "tok_visa"}))
            end

            before do
              @usecase = Publish.new(stripe: stripe).execute(reference: job_listing.reference, account: admin_account)
            end

            it "triggers stripe to capture a payment" do
              expect(stripe).to have_received(:capture_job_listing_charge).with(stripe_charge_id: @usecase.job_listing.stripe_charge_id)
            end

            it "sets the paid date on a job listing" do
              expect(@usecase.job_listing.paid_at).to be_truthy
            end

            it "sets the published date on a job listing" do
              expect(@usecase.job_listing.published_at).to be_truthy
            end

            xit "notifies the job listing owner"
          end
        end

        context "when non admin" do
          let(:job_listing) do
            create(:job_listing, stripe_charge_id: "123" )
          end
          let(:non_admin_account) { create(:account) }

          it "raises unauthorized error" do
            expect{Publish.new.execute(reference: job_listing.reference, account: non_admin_account)}.to raise_error(RoundedServices::Error::UnauthorizedError)
          end
        end

        context "when guest" do
          let(:job_listing) do
            create(:job_listing, stripe_charge_id: "123" )
          end

          it "raises unauthorized error" do
            expect{Publish.new.execute(reference: job_listing.reference, account: nil)}.to raise_error(RoundedServices::Error::UnauthorizedError)
          end
        end
      end

      describe Update do
        context "when admin" do
          let(:admin_account) { create(:account, admin: true) }
          let(:job_listing) { create(:job_listing) }
          let(:job_listing_repository) { instance_double(Repository::JobListing, update: true, find_by_reference: Entity::JobListing.new) }
          let(:attributes_hash) do
            attributes_hash = {
              title: "senior full stack developer"
            }
          end
          let(:form) { RoundedServices::Form::JobListing.new(attributes_hash: attributes_hash) }

          before do
            @usecase = described_class.new(job_listing_repository: job_listing_repository).execute(form: form, reference: job_listing.reference, account: admin_account)
          end

          it "triggers update on repository with job listing" do
            expect(job_listing_repository).to have_received(:update).with(form: form, reference: job_listing.reference)
          end

          it "triggers find by reference on Repository with job listing" do
            expect(job_listing_repository).to have_received(:find_by_reference).with(reference: job_listing.reference)
          end

          it "returns a job listing" do
            expect(@usecase.job_listing).to be_a(Entity::JobListing)
          end
        end

        context "when non-admin" do
          let(:job_listing) { create(:job_listing) }
          let(:job_listing_repository) { instance_double(Repository::JobListing, update: true, find_by_reference: Entity::JobListing.new) }
          let(:attributes_hash) do
            attributes_hash = {
              title: "senior full stack developer"
            }
          end
          let(:form) { RoundedServices::Form::JobListing.new(attributes_hash: attributes_hash) }

          it "raises Error::UnauthorizedError" do
            @usecase =
            expect{
              described_class.new(job_listing_repository: job_listing_repository).execute(form: form, reference: job_listing.reference)
            }.to raise_error(Error::UnauthorizedError)
          end
        end
      end

      describe Deactivate do
        context "when admin" do
          let(:admin_account) { create(:account, admin: true) }
          let(:job_listing) { create(:job_listing) }
          let(:job_listing_repository) { instance_double(Repository::JobListing, mark_as_inactive: true, find_by_reference: Entity::JobListing.new) }
          let(:attributes_hash) do
            attributes_hash = {
              title: "senior full stack developer"
            }
          end
          let(:form) { RoundedServices::Form::JobListing.new(attributes_hash: attributes_hash) }

          before do
            @usecase = described_class.new(job_listing_repository: job_listing_repository).execute(reference: job_listing.reference, account: admin_account)
          end

          it "triggers mark as inactive on repository with job listing" do
            expect(job_listing_repository).to have_received(:mark_as_inactive).with(reference: job_listing.reference)
          end

          it "triggers find by reference on Repository with job listing" do
            expect(job_listing_repository).to have_received(:find_by_reference).with(reference: job_listing.reference)
          end

          it "returns a job listing" do
            expect(@usecase.job_listing).to be_a(Entity::JobListing)
          end
        end

        context "when non-admin" do
          let(:job_listing) { create(:job_listing) }
          let(:job_listing_repository) { instance_double(Repository::JobListing, update: true, find_by_reference: Entity::JobListing.new) }
          let(:attributes_hash) do
            attributes_hash = {
              title: "senior full stack developer"
            }
          end
          let(:form) { RoundedServices::Form::JobListing.new(attributes_hash: attributes_hash) }

          it "raises Error::UnauthorizedError" do
            @usecase =
            expect{
              described_class.new(job_listing_repository: job_listing_repository).execute(reference: job_listing.reference)
            }.to raise_error(Error::UnauthorizedError)
          end
        end
      end
    end
  end
end
