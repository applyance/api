attributes :id, :access_level, :is_entity_admin, :created_at, :updated_at

child :account do
  extends 'accounts/_single'
end

child :unit do
  extends 'units/_shallow'
end
