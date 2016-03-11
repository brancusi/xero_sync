require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  handler {|job| job.perform_async}

  every(5.seconds, SyncLocalItemsWorker)
  every(5.seconds, SyncLocalLocationsWorker)
  every(5.seconds, SyncLocalSalesOrdersWorker)

  every(1.hour, SyncRemoteItemsWorker)
  every(1.hour, SyncRemoteLocationsWorker)

end
