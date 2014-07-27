attributes :id, :digest, :submitted_at, :last_activity_at, :created_at, :updated_at

child :applicant => :applicant do
  extends 'applicants/_shallow'
end

child :spots => :spots do
  extends 'spots/_shallow'
end

child :units => :units do
  extends 'units/_shallow'
end

child :entities => :entities do
  extends 'entities/_shallow'
end

child :stage => :stage do
  extends 'stages/_shallow'
end

child :labels => :labels do
  extends 'labels/_shallow'
end

child :reviewers => :reviewers do
  extends 'reviewers/_shallow'
end

child :fields => :fields do
  extends 'fields/_application'
end
