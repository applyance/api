attributes :id, :created_at, :updated_at

child :address => :address do
  extends 'addresses/_shallow'
end

child :coordinate => :coordinate do
  extends 'coordinates/_shallow'
end
