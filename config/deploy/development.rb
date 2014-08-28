server 'dev.applyance.com',
  user: 'deploy',
  roles: %w{web app db},
  primary: true

set :stage, :development
set :deploy_to, "/srv/www/api.applyance.com"
