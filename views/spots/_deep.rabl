attributes :id, :name, :detail, :status, :created_at, :updated_at

child :unit do
  extends 'units/_shallow'
end
