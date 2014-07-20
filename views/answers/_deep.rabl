attributes :id, :answer, :created_at, :updated_at

child :account do
  extends 'accounts/_shallow'
end

child :definition do
  extends 'definitions/_shallow'
end

child :attachments do
  extends 'attachments/_shallow'
end
