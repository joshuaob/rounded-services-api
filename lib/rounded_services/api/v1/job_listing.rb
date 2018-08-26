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

        options "/job-listings/:id/deactivate" do
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

          if params[:page]
            request_url = request.url
            collection_url = request_url.split("?").first
            current_page = params[:page][:number].to_i
            page_size = params[:page][:size].to_i
            next_page = current_page + 1
            previous_page = current_page == 1 ? nil : current_page - 1
            total_pages = (Repository::JobListing.new.count_published / page_size.to_f).ceil
            first_page = 1
            last_page = total_pages

            form.page_size = page_size
            form.page_no = current_page
          else
            form.page_size = 25
            form.page_no = 1
          end


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

                links = {}
                links[:pagination] = {}
                links[:pagination][:current] = current_page
                links[:pagination][:prev] = previous_page
                links[:pagination][:next] = next_page
                links[:pagination][:first] = first_page
                links[:pagination][:last] = last_page

                # links[:self] = "#{collection_url}?page[number]=#{current_page}&page[size]=#{page_size}"
                # links[:prev] = "#{collection_url}?page[number]=#{previous_page}&page[size]=#{page_size}"
                # links[:next] = "#{collection_url}?page[number]=#{next_page}&page[size]=#{page_size}"
                # links[:first] = "#{collection_url}?page[number]=1&page[size]=5"
                # links[:last] = "#{collection_url}?page[number]=13&page[size]=5"

                body job_listing_serializer.serialize(usecase.job_listings, is_collection: true, meta: {links: links}).to_json
              end
            end
          end

          # halt 422, "invalid filter"
        end

        patch '/job-listings/:id/publish' do
          usecase = RoundedServices::Usecase::JobListing::Publish.new.execute(reference: params[:id], account: find_or_create_account)
          job_listing_serializer.serialize(usecase.job_listing).to_json
        end

        patch '/job-listings/:id/deactivate' do
          usecase = RoundedServices::Usecase::JobListing::Deactivate.new.execute(reference: params[:id], account: find_or_create_account)
          job_listing_serializer.serialize(usecase.job_listing).to_json
        end

        patch '/job-listings/:id' do
          if attributes_hash.nil?
            usecase = RoundedServices::Usecase::JobListing::FindOne.execute(reference: params[:id])
            return job_listing_serializer.serialize(usecase.job_listing).to_json
          end

          form = RoundedServices::Form::JobListing.new(attributes_hash: attributes_hash)
          usecase = RoundedServices::Usecase::JobListing::Update.new.execute(form: form,reference: params[:id], account: find_or_create_account)
          job_listing_serializer.serialize(usecase.job_listing).to_json
        end
      end
    end
  end
end
