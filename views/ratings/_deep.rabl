attributes :id, :rating, :created_at, :updated_at

child :application => :application do
  extends 'applications/_shallow'
end

child :spot => :spot do
  extends 'spots/_shallow'
end

child :reviewer => :reviewer do
  extends 'reviewers/_shallow'
end
