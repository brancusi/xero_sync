namespace :sync do

  desc "Sync all unsynced records to xero"

  task :all => :environment do

    redis = Redis.new

    last_sync = Maybe(redis.get("xero_syncer_last_synced")).fetch(100.years.ago.to_s)
    
    last_synced_timestamp = DateTime.parse(last_sync)

    new_timestamp = DateTime.now

    client_models = Client.where("updated_at > ?", last_synced_timestamp)
    item_models = Item.where("updated_at > ?", last_synced_timestamp)
    sales_orders = SalesOrder.where(invoiced:true).where("updated_at > ?", last_synced_timestamp)

    begin
      XeroContactsSyncer.new.sync(client_models)
    rescue
      p 'Contact Sync Failed'
    end

    begin
      XeroItemsSyncer.new.sync(item_models)
    rescue
      p 'Item Sync Failed'
    end

    begin
      XeroInvoicesSyncer.new.sync(sales_orders)
    rescue => errors
      p "Invoice Sync Failed #{errors}"
    end

    redis.set("xero_syncer_last_synced", new_timestamp)
  end

end
