attributes :id, :phone_number, :created_at, :updated_at

child :account => :account do
  extends 'accounts/_shallow'
end

child :location => :location do
  extends 'locations/_deep'
end

child :stage => :stage do
  extends 'stages/_shallow'
end

child :ratings => :ratings do
  extends 'ratings/_shallow'
end

child :labels => :labels do
  extends 'labels/_shallow'
end
