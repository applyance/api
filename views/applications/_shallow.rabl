attributes :id, :digest, :submitted_from_id, :submitted_at, :last_activity_at, :created_at, :updated_at

child :submitter => :submitter do
  extends 'accounts/_shallow'
end

child :spots => :spots do
  extends 'spots/_shallow'
end

child :stage => :stage do
  extends 'stages/_shallow'
end
