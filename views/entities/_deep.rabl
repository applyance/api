attributes :id, :name, :slug, :stripe_customer_id, :created_at, :updated_at

child :domain => :domain do
  extends 'domains/_shallow'
end

child :logo => :logo do
  extends 'attachments/_shallow'
end

child :location => :location do
  extends 'locations/_deep'
end

child :parent => :parent do
  extends 'entities/_shallow'
end

child :reviewers => :reviewers do
  extends 'reviewers/_shallow'
end
