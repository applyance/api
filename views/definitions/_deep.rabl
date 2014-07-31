attributes :id, :name, :label, :description, :type, :helper, :created_at, :updated_at

child :domain => :domain do
  extends "domains/_shallow"
end

child :entity => :entity do
  extends "entities/_shallow"
end
