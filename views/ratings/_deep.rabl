attributes :id, :rating, :created_at, :updated_at

child :application => :application do
  extends 'applications/_shallow'
end

child :account => :account do
  extends 'accounts/_shallow'
end
