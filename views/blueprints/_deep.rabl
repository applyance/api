attributes :id, :position, :is_required, :created_at, :updated_at

child :definition => :definition do
  extends 'definitions/_shallow'
end
