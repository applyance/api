attributes :id, :location_id, :stage_id, :phone_number, :created_at, :updated_at

child :account => :account do
  extends 'accounts/_shallow'
end

child :ratings => :ratings do
  extends 'ratings/_shallow'
end

node(:label_ids) do |citizen|
  citizen.labels.collect(&:id)
end
