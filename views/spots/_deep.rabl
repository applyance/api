attributes :id, :name, :slug, :detail, :status, :created_at, :updated_at

child :entity => :entity do
  extends 'entities/_shallow'
end

node(:citizen_count) do |spot|
  spot.get_citizens.count
end
