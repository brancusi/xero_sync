require 'test_helper'

class SalesOrdersSyncerTest < ActiveSupport::TestCase

  # Local sync testing
  test "Should sync local sales_orders when they don't exist in xero" do
    company = Company.create(name:'Nature Well')
    location = Location.create(name:'Silverlake', code:'NW001', company:company)
    Order.create(order_type:'sales-order', location:location, delivery_date:Date.today + 1)

    VCR.use_cassette('sales_orders/001') do
      SalesOrdersSyncer.new.sync_local(10.minutes.ago)
    end

    assert Order.first.xero_id.present?
  end

end
