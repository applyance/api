attributes :id, :application_id, :created_at, :updated_at

child :datum => :datum do
  extends 'datums/_application'
end
