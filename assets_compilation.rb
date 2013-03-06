namespace :assets do
  desc "Compress assets in a local file"
  task :compress_assets do
    run_locally("rm -rf public/assets/*")
    run_locally("bundle exec rake assets:precompile")
    run_locally("touch assets.tgz && rm assets.tgz")
    run_locally("tar zcvf assets.tgz public/assets/")
    run_locally("mv assets.tgz public/assets/")
  end
  before "deploy:update_code", "assets:compress_assets"
  
  desc "Upload assets"
  task :upload_assets do
    upload("public/assets/assets.tgz", release_path + '/assets.tgz', via: :scp)
    run "cd #{release_path}; tar zxvf assets.tgz; rm assets.tgz"
  end
  after "deploy:finalize_update", "assets:upload_assets"

  desc "Remove assets unpacked"
  task :remove_assets do
    run_locally("rm -rf public/assets/*")
  end
  after "assets:upload_assets", "assets:remove_assets"
end

