require 'test_helper'

class LocationsSyncerTest < ActiveSupport::TestCase

  test "Local sync locations" do
    result = nil

    Location.all.each {|loc|
       refute loc.xero_id, 'xero_id was not nil'
    }

    VCR.use_cassette('[Xero - Contact]: xero_id missing, search by name, 0 results, save locations') do
      result = LocationsSyncer.new.sync_local(100.years.ago)
    end

    Location.all.each {|loc|
       assert result.select {|record| record.contact_id == loc.xero_id}.first.present?, 'No record found for response'
    }
  end

end
