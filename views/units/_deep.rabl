attributes :id, :name, :created_at, :updated_at

child :entity => :entity do
  extends 'entities/_shallow'
end

child :logo => :logo do
  extends 'attachments/_shallow'
end
