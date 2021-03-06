set_default(:postgresql_host, "localhost")
set_default(:postgresql_user) { application }
set_default(:postgresql_password) { Capistrano::CLI.password_prompt "PostgreSQL Password: " }
set_default(:postgresql_database) { "#{application}_#{rails_env}" }

namespace :postgres do
  desc "Create a database for this application."
  task :drop_database, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "drop database #{postgresql_database};"}
    run %Q{#{sudo} -u postgres psql -c "drop user #{postgresql_user};"}
  end

  desc "Create a database for this application."
  task :create_database, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "create user #{postgresql_user} with password '#{postgresql_password}';"}
    run %Q{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user};"}
  end
  before "postgres:setup", "postgres:create_database"

  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "postgres.yml.erb", "#{shared_path}/config/database.yml"
  end
  after "deploy:setup", "postgres:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "postgres:symlink"
end
