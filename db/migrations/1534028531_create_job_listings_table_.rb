Sequel.migration do
  up do
    create_table(:job_listings) do
      primary_key :id
      String :reference, null: false, unique: true
      String :title, null: false
      String :url, null: false
      String :email, null: false
      String :keywords, null: false, text: true
      String :employer
      String :job_type, null: false
      String :commute_type, null: false
      String :salary, null: false
      Integer :account_id
      String :location
      String :stripe_charge_id
    end

    add_column :job_listings, :created_at, 'timestamp with time zone', null: false
    add_column :job_listings, :published_at, 'timestamp with time zone'
    add_column :job_listings, :paid_at, 'timestamp with time zone'
  end

  down do
    drop_table(:job_listings)
  end
end
