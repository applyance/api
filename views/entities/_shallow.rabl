attributes :id, :name, :slug, :domain_id, :parent_id, :created_at, :updated_at

child :logo => :logo do
  extends 'attachments/_shallow'
end

child :location => :location do
  extends 'locations/_deep'
end
