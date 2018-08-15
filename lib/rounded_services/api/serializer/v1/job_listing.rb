module RoundedServices
  module API
    module Serializer
      module V1
        class JobListing
          include JSONAPI::Serializer

          attribute :title

          attribute :keywords
          attribute :email
          attribute :job_type
          attribute :commute_type
          attribute :salary
          attribute :url
          attribute :employer
          attribute :published
          attribute :location
          attribute :published_at do
            if object.published_at
              object.published_at.iso8601
            else
              object.published_at
            end
          end

          attribute :created_at do
            object.created_at.iso8601
          end

          def id
            object.reference
          end

          def self_link
            nil
          end

          def format_name(attribute_name)
            attribute_name.to_s.underscore
          end
        end
      end
    end
  end
end
