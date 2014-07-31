attributes :id, :email, :status, :scope, :created_at, :updated_at

child :entity => :entity do
  extends 'entities/_shallow'
end
