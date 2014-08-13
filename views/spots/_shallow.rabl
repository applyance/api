attributes :id, :entity_id, :name, :slug, :detail, :status, :created_at, :updated_at

node(:citizen_count) do |spot|
  spot.get_citizens.count
end
