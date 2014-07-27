attributes :id, :name, :created_at, :updated_at

child :domain => :domain do
  extends 'domains/_shallow'
end

child :logo => :logo do
  extends 'attachments/_shallow'
end
