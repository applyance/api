desc "Start dev server (via rerun)"
task :start_dev_server do
  sh "rerun --pattern '**/*.{rb,erb,ru,yml,rabl}' --signal KILL -- thin start --debug --port 3001 --environment development"
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
