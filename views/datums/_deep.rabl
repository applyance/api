attributes :id, :detail, :created_at, :updated_at

child :applicant => :applicant do
  extends 'applicants/_shallow'
end

child :definition => :definition do
  extends 'definitions/_shallow'
end

child :attachments => :attachments do
  extends 'attachments/_shallow'
end
