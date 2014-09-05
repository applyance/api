desc "Start dev server (via rerun)"
task :start_dev_server do
  sh "rerun --pattern '**/*.{rb,erb,ru,yml,rabl}' --signal KILL -- thin start --debug --port 3001 --environment development"
end

desc "Properly merges the dev branch into master."
task :prepare_master_for_deploy do
  branch = %x[git rev-parse --abbrev-ref HEAD].strip
  unless branch == "master"
    abort "Not on master branch. Can't proceed. Switch to the master branch to run this command."
  end

  puts "Fetching latest from git."
  sh "git fetch"

  puts "Merging dev into master, but not committing just yet."
  sh "git merge --no-commit dev"

  puts "Checking out original files from master (.travis.yml, README.md)."
  sh "git checkout origin/master -- .travis.yml"
  sh "git checkout origin/master -- README.md"

  puts "Committing changes."
  sh "git commit -m 'Merging dev into master.'"

  puts "All done. If all is well, push commits to origin to initiate build and deployment."
end

desc "Encrypt the configuration."
task :encrypt_config do
  key = ''
  STDOUT.puts "What is the encryption key?"
  key = STDIN.gets.chomp

  sh "openssl aes-256-cbc -k \"#{key}\" -in config/config.yml -out config/config.development.yml.enc"
  sh "openssl aes-256-cbc -k \"#{key}\" -in config/config.production.yml -out config/config.production.yml.enc"
end

namespace :travis do

  desc "Decrypt."
  task :decrypt do
    branch = %x[git rev-parse --abbrev-ref HEAD].strip
    environment = (branch == "master") ? "production" : "development"

    sh "openssl aes-256-cbc -k \"$chicken_sandwiches\" -in config/config.#{environment}.yml.enc -out config/config.yml -d"
  end

  desc "Deploy based on branch."
  task :deploy do
    branch = %x[git rev-parse --abbrev-ref HEAD].strip
    environment = (branch == "master") ? "production" : "development"

    sh "bundle exec cap #{environment} deploy"
  end

end
