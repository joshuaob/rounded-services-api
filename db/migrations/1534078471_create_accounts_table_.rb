Sequel.migration do
  up do
    create_table(:accounts) do
      primary_key :id
      String :reference, null: false, unique: true
      String :email, null: false, unique: true
      TrueClass :admin, null: false, default: false
    end

    add_column :accounts, :created_at, 'timestamp with time zone', null: false
  end

  down do
    drop_table(:accounts)
  end
end
