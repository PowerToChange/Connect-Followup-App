require 'capistrano/ext/multistage'
require 'bundler/capistrano'


set :stages, %w(staging production)
set :default_stage, "staging"
set :deploy_via, :remote_cache
set :scm, :git

set :application, "connect_followup_app"
set :repository,  "git@github.com:PowerToChange/Connect-Followup-App.git"

after "deploy:restart", "deploy:cleanup"


# Symlinking
namespace :config do
  desc 'Symlink config files into latest release'
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml"
    run "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
    run "ln -nfs #{shared_path}/tmp/sessions #{release_path}/tmp/sessions"
  end
  after 'deploy:finalize_update', 'config:symlink'
end


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