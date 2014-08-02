attributes :id, :digest, :submitted_at, :last_activity_at, :created_at, :updated_at

child :applicant => :applicant do
  extends 'applicants/_shallow'
end

child :spots => :spots do
  extends 'spots/_shallow'
end

child :entities => :entities do
  extends 'entities/_shallow'
end

child :stage => :stage do
  extends 'stages/_shallow'
end

child :ratings => :ratings do
  extends 'ratings/_shallow'
end

node(:label_ids) do |application|
  application.labels.collect(&:id)
end

node(:reviewer_ids) do |application|
  application.reviewers.collect(&:id)
end
