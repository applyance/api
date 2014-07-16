Sequel.migration do
  change do

    # Create errors
    create_table(:errors) do
      primary_key :id

      String :status
      String :title
      String :detail
      String :path
      String :backtrace

      DateTime :created_at
    end

  end
end
