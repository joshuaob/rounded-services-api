module RoundedServices
  module Usecase
    module JobListing
      describe Create do
        context "when admin" do
          let(:stripe) { instance_double(Service::Stripe, authorize_job_listing_charge: OpenStruct.new(id: "123")) }
          let(:usecase) do
            account = Repository::Account.new.create(email: "joshuaaob@gmail.com")
            form = Factory::JobListing.build(attributes_hash: {account: account})
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
              form = Factory::JobListing.build
              expect{Create.new.execute(form: form)}.to raise_error(RoundedServices::Error::MissingStipeTokenError)
            end
          end

          context "when stripe token is present" do
            let(:stripe) { instance_double(Service::Stripe, authorize_job_listing_charge: OpenStruct.new(id: "123")) }
            let(:form) { Factory::JobListing.build(attributes_hash: { stripe_token: "tok_visa" }) }
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
            let(:admin_account) { Repository::Account.new.create(email: "joshuaaob@gmail.com") }
            let(:job_listing) do
              Factory::JobListing.create(form: Factory::JobListing.build(attributes_hash: { account: admin_account }))
            end
            before do
              @usecase = Publish.new(stripe: stripe).execute(reference: job_listing.reference, account: admin_account)
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

            it "notifies the job listing owner"
          end

          context "when publishing job listings by others" do
            let(:admin_account) { Repository::Account.new.create(email: "joshuaaob@gmail.com") }
            let(:non_admin_account) { Repository::Account.new.create(email: "user@rounded.services") }
            let(:job_listing) do
              Factory::JobListing.create(form: Factory::JobListing.build(attributes_hash: { account: non_admin_account, stripe_token: "tok_visa"}))
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

            it "notifies the job listing owner"
          end
        end

        context "when non admin" do
          let(:job_listing) do
            account = Repository::Account.new.create(email: "joshuaaob@gmail.com")
            Factory::JobListing.create(form: Factory::JobListing.build(attributes_hash: {account: account}))
          end
          let(:non_admin_account) { Repository::Account.new.create(email: "guest@rounded.services") }

          it "raises unauthorized error" do
            expect{Publish.new.execute(reference: job_listing.reference, account: non_admin_account)}.to raise_error(RoundedServices::Error::UnauthorizedError)
          end
        end

        context "when guest" do
          let(:job_listing) do
            account = Repository::Account.new.create(email: "joshuaaob@gmail.com")
            Factory::JobListing.create(form: Factory::JobListing.build(attributes_hash: {account: account}))
          end

          it "raises unauthorized error" do
            expect{Publish.new.execute(reference: job_listing.reference, account: nil)}.to raise_error(RoundedServices::Error::UnauthorizedError)
          end
        end
      end
    end
  end
end

# module RoundedServices
#   module Service
#     module JobListing
#       describe CaptureCharge do
#         context "when admin" do
#           it "does something"
#         end
#
#         context "when guest" do
#           it "does something"
#         end
#       end
#       describe Refund do
#         context "when admin" do
#           it "does something"
#         end
#
#         context "when guest" do
#           it "does something"
#         end
#       end
#     end
#
#     module JobListing
#       describe FindCharge do
#         context "when admin" do
#           it "does something"
#         end
#
#         context "when guest" do
#           it "does something"
#         end
#       end
#     end
#   end
# end
