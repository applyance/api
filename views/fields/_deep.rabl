attributes :id, :created_at, :updated_at

child :application do
  extends 'applications/_shallow'
end

child :blueprint do
  extends 'blueprints/_shallow'
end

child :answer do
  extends 'answers/_shallow'
end
