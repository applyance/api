attributes :id, :name, :domain_id, :location_id, :created_at, :updated_at

child :logo => :logo do
  extends 'attachments/_shallow'
end
