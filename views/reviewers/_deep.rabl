attributes :id, :access_level, :is_entity_admin, :created_at, :updated_at

child :account => :account do
  extends 'accounts/_shallow'
end

child :unit => :unit do
  extends 'units/_shallow'
end
