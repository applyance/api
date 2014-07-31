attributes :id, :name, :color, :created_at, :updated_at

child :entity => :entity do
  extends 'entities/_shallow'
end
