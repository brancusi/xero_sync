LAST_LOCAL_SYNC_KEY = 'xero_last_local_sync'
LAST_REMOTE_SYNC_KEY = 'xero_last_remote_sync'

namespace :sync do

  desc 'Sync all local then remote changes'
  task :all => ["sync:local", "sync:remote"]

  desc 'Sync all local data to xero'
  task :local => :environment do

    redis = Redis.new

    # If this is the first time we are syncing, let's go back to the start of time
    last_sync_date_time = Maybe(redis.get(LAST_LOCAL_SYNC_KEY)).fetch(100.years.ago.to_s)
    last_sync = DateTime.parse(last_sync_date_time)

    new_timestamp = DateTime.now

    # item_models = Item.where('updated_at > ?', last_synced_timestamp)
    # location_models = Location.where('updated_at > ?', last_synced_timestamp)
    # order_models = Order.where(fullfilled:true, order_type:'sales-order').where('updated_at > ?', last_synced_timestamp)

    begin
      XeroItemsSyncer.new.sync_local(last_sync)
    rescue => errors
      p "Remote Item sync error: #{errors}"
    end

    # begin
    #   XeroContactsSyncer.new.sync(location_models)
    # rescue => errors
    #   p "Contacts sync error: #{errors}"
    # end
    #
    # begin
    #   XeroInvoicesSyncer.new.sync(order_models)
    # rescue => errors
    #   p "Invoice sync error: #{errors}"
    # end

    redis.set(LAST_LOCAL_SYNC_KEY, new_timestamp)
  end

  desc 'Sync all remote xero records to to local'
  task :remote => :environment do

    redis = Redis.new

    # If this is the first time we are syncing, let's go back to the start of time
    last_sync_date_time = Maybe(redis.get(LAST_REMOTE_SYNC_KEY)).fetch(100.years.ago.to_s)

    last_sync = DateTime.parse(last_sync_date_time)

    new_timestamp = DateTime.now

    # item_models = Item.where('updated_at > ?', last_synced_timestamp)
    # location_models = Location.where('updated_at > ?', last_synced_timestamp)
    # order_models = Order.where(fullfilled:true, order_type:'sales-order').where('updated_at > ?', last_synced_timestamp)

    begin
      XeroItemsSyncer.new.sync_remote(last_sync)
    rescue => errors
      p "Remote Item sync error: #{errors}"
    end

    # begin
    #   XeroContactsSyncer.new.sync(location_models)
    # rescue => errors
    #   p "Contacts sync error: #{errors}"
    # end
    #
    # begin
    #   XeroInvoicesSyncer.new.sync(order_models)
    # rescue => errors
    #   p "Invoice sync error: #{errors}"
    # end

    redis.set(LAST_REMOTE_SYNC_KEY, new_timestamp)
  end

end
