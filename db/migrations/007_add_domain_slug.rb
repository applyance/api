class MigrationHelper_007
  extend Applyance::Lib::Strings
end

Sequel.migration do
  up do
    add_column :domains, :slug, String
    add_column :domains, :'_slug', String

    # Assign slugs to domains
    Applyance::Server.db[:domains].each do |domain|
      slug = MigrationHelper_007.to_slug(domain[:name], '')
      Applyance::Server.db[:domains].where(:id => domain[:id]).update(
        :slug => slug,
        :'_slug' => slug
      )
    end

    # Assign entities to first domain
    domain = Applyance::Server.db[:domains].order(:created_at).first
    if domain
      Applyance::Server.db[:entities].update(:domain_id => domain[:id])
    end
  end
  down do
    drop_column :domains, :slug
    drop_column :domains, :'_slug'

    # Nullify the domain for the entities
    Applyance::Server.db[:entities].update(:domain_id => nil)
  end
end
