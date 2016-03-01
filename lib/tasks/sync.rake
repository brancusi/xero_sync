
namespace :sync do

  desc 'Sync all unsynced records to xero'

  task :all => :environment do

    redis = Redis.new

    # If this is the first time we are syncing, let's go back to the start of time
    last_sync = Maybe(redis.get('xero_syncer_last_synced')).fetch(100.years.ago.to_s)

    last_synced_timestamp = DateTime.parse(last_sync)

    new_timestamp = DateTime.now

    location_models = Location.where('updated_at > ?', last_synced_timestamp)
    item_models = Item.where('updated_at > ?', last_synced_timestamp)
    order_models = Order.where(fullfilled:true, order_type:'sales-order').where('updated_at > ?', last_synced_timestamp)

    # begin
    #   XeroContactsSyncer.new.sync(location_models)
    # rescue
    #   p 'Contacts Sync Failed'
    # end
    #
    # begin
    #   XeroItemsSyncer.new.sync(item_models)
    # rescue
    #   p 'Items Sync Failed'
    # end

    begin
      XeroInvoicesSyncer.new.sync(order_models)
    rescue => errors
      p "Invoices Sync Failed #{errors}"
    end

    # redis.set('xero_syncer_last_synced', new_timestamp)
  end

end
