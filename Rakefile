desc "Start server (via rerun)"
task :start do
  sh "rerun --dir routes,db,helpers,lib,models,config,views --signal KILL -- thin start --debug --port 3001 --environment development"
end
