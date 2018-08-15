require_relative '../serializer/v1/job_listing'

module RoundedServices
  module API
    class V1 < Sinatra::Base
      def job_listing_serializer
        result = "RoundedServices::API::Serializer::V#{requested_api_version}::JobListing"
        result.constantize
      rescue NameError => e
        @api_error_handler.handle_invalid_api_version_error(requested_api_version)
        halt 500, JSONAPI::Serializer.serialize_errors(@api_error_handler.errors).to_json
      end

      namespace '/v1' do
        options "/job-listings" do
        end

        options "/job-listings/:id" do
        end

        options "/job-listings/:id/publish" do
        end

        get '/status' do
          body "#{@config.env} up and running."
        end

        post "/job-listings" do
          jwt = env["HTTP_AUTHORIZATION"].split[-1]

          if jwt != "undefined"
            account = find_or_create_account
            form = RoundedServices::Form::JobListing.new(attributes_hash: attributes_hash.merge({account: account}))
          else
            form = RoundedServices::Form::JobListing.new(attributes_hash: attributes_hash)
          end

          usecase = RoundedServices::Usecase::JobListing::Create.new.execute(form: form)
          job_listing_serializer.serialize(usecase.job_listing).to_json
        end

        get "/job-listings/:id" do
          usecase = RoundedServices::Usecase::JobListing::FindOne.execute(reference: params[:id])
          job_listing_serializer.serialize(usecase.job_listing).to_json
        end

        get "/job-listings" do

          form = OpenStruct.new
          form.page_size = 25
          form.page_no = 1

          # binding.pry

          if params[:filter]
            if params[:filter][:published]
              if params[:filter][:published] == "false"
                account = find_or_create_account
                form.account = account
                usecase = RoundedServices::Usecase::JobListing::FindUnpublished.execute(form: form)
                body job_listing_serializer.serialize(usecase.job_listings, is_collection: true).to_json
              end

              if params[:filter][:published] == "true"
                usecase = RoundedServices::Usecase::JobListing::FindPublished.execute(form: form)
                body job_listing_serializer.serialize(usecase.job_listings, is_collection: true).to_json
              end
            end
          end

          # halt 422, "invalid filter"
        end

        patch '/job-listings/:id/publish' do
          usecase = RoundedServices::Usecase::JobListing::Publish.new.execute(reference: params[:id], account: find_or_create_account)
          job_listing_serializer.serialize(usecase.job_listing).to_json
        end
      end
    end
  end
end
