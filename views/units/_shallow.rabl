attributes :id, :entity_id, :name, :created_at, :updated_at

child :logo => :logo do
  extends 'attachments/_shallow'
end
