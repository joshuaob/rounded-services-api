FactoryBot.define do
  factory :job_listing, class: RoundedServices::Entity::JobListing do
    to_create { |instance| RoundedServices::Repository::JobListing.new.save(job_listing: instance) }

    sequence(:email) { |n| "account#{n}@rounded.services" }
    title { "full stack engineer" }
    url { "https://rounded.services" }
    keywords { "ruby, javascript, rails, angular, postgresql, docker" }
    job_type { "permanent" }
    commute_type { "part remote" }
    salary { "£50k DOE" }
  end
end


# :keywords,
# :email,
# :title,
# :job_type,
# :commute_type,
# :salary,
# :url,
# :employer,
# :published,
# :account_id,
# :location,
# :published_at,
# :paid_at,
# :stripe_charge_id
