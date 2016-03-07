require 'test_helper'

class ItemsSyncerTest < ActiveSupport::TestCase

  # test "Items without xero_id should receive one after local sync" do
  #   result = nil
  #
  #   assert Item.first.xero_id.nil?, "xero_id was not nil, expected to be nil unsynced model"
  #
  #   VCR.use_cassette('sync local items with xero - EMPTY - Items') do
  #     result = ItemsSyncer.new.sync_local
  #   end
  #
  #   assert result.first.item_id == Item.first.xero_id
  # end
  #
  # test "remote sync" do
  #   result = nil
  #
  #   VCR.use_cassette('sync remote items locally - Item 1 - Changed') do
  #     result = ItemsSyncer.new.sync_remote
  #   end
  #
  #   assert result.first.item_id == Item.first.xero_id
  # end
end
