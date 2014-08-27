lock '3.2.1'

set :application, 'Applyance API'
set :scm, :git
set :linked_dirs, %w{bin log tmp/pids}
set :keep_releases, 5

namespace :travis do

	desc 'Check that travis is reachable'
	task :check do
		exit 1 unless true
	end

	desc 'Package to release'
	task :create_release do
		run_locally do
			execute :mkdir, '-p', :'tmp'
			execute "tar -cz --exclude tests --exclude vendor --exclude .git --exclude node_modules --exclude tmp/#{fetch(:release_timestamp)}.tar.gz -f tmp/#{fetch(:release_timestamp)}.tar.gz ."
		end
		on release_roles :all do
			execute :mkdir, '-p', release_path
			upload! "tmp/#{fetch(:release_timestamp)}.tar.gz", "#{release_path}/#{fetch(:release_timestamp)}.tar.gz"
			execute "tar -xvf #{release_path}/#{fetch(:release_timestamp)}.tar.gz --directory #{release_path}"
			execute "rm #{release_path}/#{fetch(:release_timestamp)}.tar.gz"
		end
		run_locally do
			execute "rm -rf tmp"
		end
	end

	desc 'Determine the revision that will be deployed'
	task :set_current_revision do
		set :current_revision, "12345"
	end

end

namespace :deploy do

	desc 'Use Travis'
	task :use_travis do
		set :scm, :travis
	end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
			if test "[ -f #{current_path}/tmp/pids/thin.pid ]"
				within current_path do
					execute :bundle, :exec, "thin restart --port 3001 --environment #{fetch(:stage)} --daemonize"
				end
		  else
				within current_path do
					execute :bundle, :exec, "thin start --port 3001 --environment #{fetch(:stage)} --daemonize"
				end
			end
    end
  end

	desc 'Migrate database'
	task :migrate do
		execute :bundle, :exec, :rake, '-f', 'db/migrate.rake', 'db:migrate'
	end

	before :starting, :use_travis
	after :publishing, :migrate
	after :publishing, :restart

end
