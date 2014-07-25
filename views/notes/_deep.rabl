attributes :id, :note, :created_at, :updated_at

child :application => :application do
  extends 'applications/_shallow'
end

child :reviewer => :reviewer do
  extends 'reviewers/_shallow'
end
