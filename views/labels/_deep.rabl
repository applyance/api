attributes :id, :name, :color, :created_at, :updated_at

child :unit => :unit do
  extends 'units/_shallow'
end
