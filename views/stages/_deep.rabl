attributes :id, :name, :position, :created_at, :updated_at

child :pipeline => :pipeline do
  extends 'pipelines/_shallow'
end
