attributes :id, :name, :slug, :domain_id, :created_at, :updated_at

child :logo => :logo do
  extends 'attachments/_shallow'
end

child :parent => :parent do
  extends 'entities/_shallow'
end

child :location => :location do
  extends 'locations/_deep'
end
