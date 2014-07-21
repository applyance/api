attributes :id, :email, :status, :access_level, :created_at, :updated_at

child :unit => :unit do
  extends 'units/_shallow'
end
