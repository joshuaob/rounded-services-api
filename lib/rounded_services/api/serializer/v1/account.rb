module RoundedServices
  module API
    module Serializer
      module V1
        class Account
          include JSONAPI::Serializer

          attribute :admin

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
