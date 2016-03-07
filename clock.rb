require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  handler {|job| job.perform_async}

  every(5.seconds, SyncLocalItemsWorker)
  every(5.seconds, SyncLocalLocationsWorker)

  every(1.hour, SyncLocalItemsWorker)
  every(1.hour, SyncRemoteLocationsWorker)
end
