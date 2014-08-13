attributes :id, :phone_number, :created_at, :updated_at

child :account => :account do
  extends 'accounts/_shallow'
end

child :location => :location do
  extends 'locations/_deep'
end
