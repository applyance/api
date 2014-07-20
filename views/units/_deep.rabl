attributes :id, :name, :created_at, :updated_at

child :entity do
  extends 'entities/_single'
end
