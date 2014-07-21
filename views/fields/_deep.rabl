attributes :id, :created_at, :updated_at

child :application => :application do
  extends 'applications/_shallow'
end

child :datum => :datum do
  extends 'datums/_shallow'
end
