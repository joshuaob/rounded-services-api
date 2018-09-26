Sequel.migration do
  change do
    add_column :job_listings, :featured_at, 'timestamp with time zone'
  end
end
