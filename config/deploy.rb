lock '3.2.1'

set :application, 'Applyance API'
set :scm, :git
set :linked_dirs, %w{bin log tmp/pids}
set :keep_releases, 5
set :thin_pid, ->{ "#{current_path}/tmp/pids/thin.pid" }

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

namespace :thin do

	desc 'Stop Thin'
	task :stop do
		on roles(:app) do
			if test("[ -f #{fetch(:thin_pid)} ]")
				within current_path do
					execute :bundle, "exec thin stop -O --tag '#{fetch(:application)} #{fetch(:stage)}' -C config/thin/#{fetch(:stage)}.yml"
				end
			end
		end
	end

	desc 'Start Unicorn'
	task :start do
		on roles(:app) do
			within current_path do
				execute :bundle, "exec thin start -O --tag '#{fetch(:application)} #{fetch(:stage)}' -C config/thin/#{fetch(:stage)}.yml"
			end
		end
	end

	desc 'Reload Thin without killing master process'
	task :reload do
		on roles(:app) do
			if test("[ -f #{fetch(:thin_pid)} ]")
				execute :kill, '-s USR2', capture(:cat, fetch(:thin_pid))
			else
				error 'Thin process not running'
			end
		end
	end

	desc 'Restart Thin'
	task :restart
	before :restart, :stop
	before :restart, :start

end

namespace :db do

	desc 'Migrate database'
	task :migrate do
		on roles(:app), in: :sequence, wait: 5 do
			within current_path do
				execute :bundle, :exec, :rake, '-f', 'db/migrate.rake', "db:migrate[#{fetch(:stage)}]"
			end
		end
	end

end

namespace :deploy do

	desc 'Use Travis'
	task :use_travis do
		set :scm, :travis
	end

	before :starting, :use_travis
	after :published, "db:migrate"
	after :finished, "thin:restart"

end
