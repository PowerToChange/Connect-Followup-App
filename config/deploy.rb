require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set :stages, %w(staging)
set :default_stage, "staging"
set :deploy_via, :remote_cache
set :scm, :git

set :application, "connect-followup-app"
set :repository,  "git@github.com:PowerToChange/Connect-Followup-App.git"

after "deploy:restart", "deploy:cleanup"

# Rollbar
set :revision, `git log -n 1 --pretty=format:"%H"`
set :local_user, `whoami`
set :rollbar_token, 'a19f6779cf20490ca0339f5d7025b161'
after :deploy, 'notify_rollbar'

# Passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

# Assets, local precompile
before  'deploy:finalize_update', 'deploy:assets:symlink'
after   'deploy:update_code', 'deploy:assets:precompile'
