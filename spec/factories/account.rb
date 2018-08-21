def generate_email_suffix
  ((0..9).to_a + ('a'..'z').to_a).shuffle.sample(8).join
end

FactoryBot.define do
  factory :account, class: RoundedServices::Entity::Account do
    to_create { |instance| RoundedServices::Repository::Account.new.save(account: instance) }
    sequence(:email) { |n| "account#{generate_email_suffix}@rounded.services" }
  end
end
