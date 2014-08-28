server 'applyance.com',
  user: 'deploy',
  roles: %w{web app db},
  primary: true

set :stage, :production
set :deploy_to, "/srv/www/api.applyance.com"
