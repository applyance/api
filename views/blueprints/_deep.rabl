attributes :id, :position, :is_required, :created_at, :updated_at

child :definition => :definition do
  extends 'definitions/_shallow'
end

child :spot => :spot do
  extends 'spots/_deep'
end

child :entity => :entity do
  extends 'entities/_shallow'
end
