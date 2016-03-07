namespace :sync do

  desc 'Sync all local then remote changes'
  task :all => ["sync:local", "sync:remote"]

  desc 'Sync all local data to xero'
  task :local => ["sync:local_items"]

  desc 'Sync all local item data to xero'
  task :local_items => :environment do
    begin
      ItemsSyncer.new.sync_local
    rescue => errors
      p "Local Item sync error: #{errors}"
    end
  end

  desc 'Sync all remote item data locally'
  task :remote_items => :environment do
    begin
      ItemsSyncer.new.sync_remote
    rescue => errors
      p "Remote Item sync error: #{errors}"
    end
  end

end
