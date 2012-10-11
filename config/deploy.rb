# Please install the Engine Yard Capistrano gem
# gem install eycap --source http://gems.engineyard.com
#require "eycap/recipes"

set :keep_releases, 5
set :application,   'sample_app'
set :repository,    'git@github.com:arvindvyas/sample_app.git'
set :deploy_to,     "/data/#{application}"
set :deploy_via,    :export
set :monit_group,   "#{application}"
set :scm,           :git
set :git_enable_submodules, 1
# This is the same database name for all environments
set :production_database,'sample_app_production'

set :environment_host, 'localhost'
set :deploy_via, :remote_cache

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
default_run_options[:pty] = true # required for svn+ssh:// andf git:// sometimes

# This will execute the Git revision parsing on the *remote* server rather than locally
set :real_revision, 			lambda { source.query_revision(revision) { |cmd| capture(cmd) } }


task :sample_app_staging do
  role :web, '182.19.23.203'
  role :app, '182.19.23.203'
  role :db, '182.19.23.203', :primary => true
  set :environment_database, Proc.new { production_database }
  set :dbuser,        'root'
  set :dbpass,        'root'
  set :rails_env,     'staging'
end


# TASKS
# Don't change unless you know what you are doing!

after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:update_code","deploy:symlink_configs"

namespace :nginx do
  task :start, :roles => :app do
    sudo "nohup /etc/init.d/nginx start > /dev/null"
  end

  task :restart, :roles => :app do
    sudo "nohup /etc/init.d/nginx restart > /dev/null"
  end
end

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
 
  task :stop, :roles => :app do
    # Do nothing.
  end
 
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end


