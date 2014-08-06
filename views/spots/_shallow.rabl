attributes :id, :entity_id, :name, :slug, :detail, :status, :created_at, :updated_at

node(:application_count) do |spot|
  spot.applications.count
end
