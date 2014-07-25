attributes :id, :email, :status, :access_level, :created_at, :updated_at

child :entity => :entity do
  extends 'entities/_shallow'
end
