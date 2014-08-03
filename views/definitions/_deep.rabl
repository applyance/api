attributes :id, :name, :label, :description, :type, :helper, :is_sensitive, :is_contextual, :created_at, :updated_at

child :domain => :domain do
  extends "domains/_shallow"
end

child :entity => :entity do
  extends "entities/_shallow"
end
