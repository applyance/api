attributes :id, :created_at, :updated_at

child :account => :account do
  extends 'accounts/_shallow'
end

child :entity => :entity do
  extends 'entities/_shallow'
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

child :applications => :applications do
  attributes :id, :digest, :submitted_at, :last_activity_at, :created_at, :updated_at
  
  child :spots => :spots do
    extends 'spots/_shallow'
  end

  child :entities => :entities do
    extends 'entities/_shallow'
  end
end
