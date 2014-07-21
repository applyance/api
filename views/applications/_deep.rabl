attributes :id, :digest, :submitted_at, :last_activity_at, :created_at, :updated_at

child :submitter => :submitter do
  extends 'accounts/_shallow'
end

child :submitted_from do
  attributes :id, :lat, :lng
end

child :spots do
  extends 'spots/_shallow'
end

child :fields do
end
