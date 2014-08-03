attributes :id, :rating, :application_id, :created_at, :updated_at

child :account => :account do
  extends 'accounts/_shallow'
end
