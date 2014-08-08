attributes :id, :definition_id, :position, :is_required, :created_at, :updated_at

child :spot => :spot do
  extends 'spots/_shallow'
end

child :entity => :entity do
  extends 'entities/_shallow'
end
