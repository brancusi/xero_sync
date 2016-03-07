class SyncRemoteLocationsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, unique: :until_executed

  def perform
    LocationsSyncer.new.sync_remote
  end
end
