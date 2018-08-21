Sequel.migration do
  change do
    add_column :job_listings, :inactive_at, 'timestamp with time zone'
  end
end
