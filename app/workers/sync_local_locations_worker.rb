class SyncLocalLocationsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, unique: :until_executed

  def perform
    LocationsSyncer.new.sync_local
  end
end
