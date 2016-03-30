require 'test_helper'

class LocationsSyncerTest < ActiveSupport::TestCase

  test "Should sync local record when they don't exist in xero" do
    company = Company.create(name:'Nature Well')
    Location.create(name:'Silverlake', code:'NW001', company:company)
    Location.create(name:'Hollywood', code:'NW002', company:company)

    VCR.use_cassette('contacts/001') do
      LocationsSyncer.new.sync_local
    end

    Location.all.each {|location|
       assert location.xero_id.present?
    }
  end

  test "Should sync local model (add xero_id) when matching code found" do
    company = Company.create(name:'Nature Well')
    Location.create(name:'Silverlake', code:'NW001', company:company)

    VCR.use_cassette('contacts/002') do
      LocationsSyncer.new.sync_remote(100.years.ago)
    end

    Location.all.each {|location|
       assert location.xero_id.present?
    }
  end

end
