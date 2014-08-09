attributes :id, :digest, :submitted_at, :last_activity_at, :created_at, :updated_at

child :citizen => :citizen do
  extends 'citizens/_shallow'
end

child :spots => :spots do
  extends 'spots/_shallow'
end

child :entities => :entities do
  extends 'entities/_shallow'
end

node(:reviewer_ids) do |application|
  application.reviewers.collect(&:id)
end

node(:ratings) do |application|
  application.citizen.ratings
end
