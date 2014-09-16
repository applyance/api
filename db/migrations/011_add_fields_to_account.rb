Sequel.migration do
  up do
    alter_table(:accounts) do
      add_column :first_name, String
      add_column :last_name, String
      add_column :initials, String
    end

    Applyance::Server.db[:accounts].each do |account|
      puts "Parsing name for account [#{account[:id]}, #{account[:name]}]"

      split_name = FullNameSplitter.split(account[:name])
      Applyance::Server.db[:accounts]
        .where(:id => account[:id])
        .update(
          :first_name => split_name[0],
          :last_name => split_name[1],
          :initials => split_name.compact.map { |n| n.slice(0, 1).capitalize }.join
        )

      updated_account = Applyance::Server.db[:accounts].first(:id => account[:id])
      puts "  First name: #{updated_account[:first_name]}"
      puts "  Last name: #{updated_account[:last_name]}"
      puts "  Initials: #{updated_account[:initials]}"
    end
  end
  down do
    alter_table(:accounts) do
      drop_column :first_name, String
      drop_column :last_name, String
      drop_column :initials, String
    end
  end
end
