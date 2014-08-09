attributes :id, :rating, :created_at, :updated_at

child :citizen => :citizen do
  extends 'citizens/_shallow'
end

child :account => :account do
  extends 'accounts/_shallow'
end
