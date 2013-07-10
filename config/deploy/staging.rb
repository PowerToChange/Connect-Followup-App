set :dns_name, "50.19.252.13"

role :web, dns_name                          # Your HTTP server, Apache/etc
role :app, dns_name                          # This may be the same as your `Web` server
role :db,  dns_name, :primary => true        # This is where Rails migrations will run

set :rails_env, "staging"

set :user, "ubuntu"
set :port, 22
set :use_sudo, false
set :deploy_to, "/home/ubuntu/webprojects/Connect-Followup-App"

set :branch, "staging"
