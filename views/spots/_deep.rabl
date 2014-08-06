attributes :id, :name, :slug, :detail, :status, :created_at, :updated_at

child :entity => :entity do
  extends 'entities/_shallow'
end

node(:application_count) do |spot|
  spot.applications.count
end
