attributes :id, :name, :slug, :label, :description, :type, :helper, :is_sensitive, :is_contextual, :is_core, :created_at, :updated_at

child :domain => :domain do
  extends "domains/_shallow"
end
