attributes :id, :last_activity_at, :stage_id, :entity_id, :created_at, :updated_at

child :account => :account do
  extends 'accounts/_shallow'
end

child :ratings => :ratings do
  extends 'ratings/_shallow'
end

child :labels => :labels do
  extends 'labels/_shallow'
end

child :applications => :applications do
  attributes :id, :digest, :submitted_at, :last_activity_at, :created_at, :updated_at
end
