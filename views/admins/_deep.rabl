attributes :id, :created_at, :updated_at

child :account do
  extends 'accounts/_single'
end

child :entity do
  extends 'entities/_single'
end
