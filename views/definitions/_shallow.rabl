attributes :id, :name, :slug, :label, :description, :type, :helper, :placeholder, :is_sensitive, :is_contextual, :is_core, :is_default, :default_position, :default_is_required, :created_at, :updated_at

child :domain => :domain do
  extends "domains/_shallow"
end
