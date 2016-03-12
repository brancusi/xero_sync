require 'test_helper'

class SalesOrdersSyncerTest < ActiveSupport::TestCase

  # Local sync testing
  test "Remote deleted invoices should update to deleted locally" do

    Item.create(name:'Sunseed Chorizo', xero_id:'b3d9696b-13f3-455a-aac9-c5b26e9b71ea')

    company = Company.create(name:'Nature Well')
    location = Location.create(name:'Silverlake', code:'NW001', company:company)
    order = Order.create(order_type:'sales-order', location:location, delivery_date:Date.parse('2016-03-01'))
    order.order_number = 'voided-invoice'
    order.save

    Item.all.each do |item|
      OrderItem.create(item:item, quantity:5, unit_price:5, order:order)
    end

    order.fulfilled!

    result = nil
    VCR.use_cassette('sales_orders/002') do
      result = SalesOrdersSyncer.new.sync_local(10.minutes.ago)
    end

    order.reload

    assert order.voided?
  end

  test "Valid local sales orders should be created in xero" do

    Item.create(name:'Sunseed Chorizo', xero_id:'b3d9696b-13f3-455a-aac9-c5b26e9b71ea')

    company = Company.create(name:'Nature Well')
    location = Location.create(name:'Silverlake', code:'NW001', company:company)
    order = Order.create(order_type:'sales-order', location:location, delivery_date:Date.parse('2016-03-01'))
    order.order_number = 'valid-new-invoice'
    order.save

    Item.all.each do |item|
      OrderItem.create(item:item, quantity:5, unit_price:5, order:order)
    end

    refute order.fulfilled?
    order.fulfilled!

    result = nil
    VCR.use_cassette('sales_orders/003') do
      result = SalesOrdersSyncer.new.sync_local(10.minutes.ago)
    end

    order.reload

    assert order.xero_id.present?
    assert order.fulfilled?
  end



  # test "Valid local sales orders should be created in xero" do
  #
  #   Item.create(name:'Sunseed Chorizo', xero_id:'b3d9696b-13f3-455a-aac9-c5b26e9b71ea')
  #
  #   company = Company.create(name:'Nature Well')
  #   location = Location.create(name:'Silverlake', code:'NW001', company:company)
  #   temp_order = Order.create(order_type:'sales-order', location:location, delivery_date:Date.parse('2016-03-01'))
  #   order = Order.create(order_type:'sales-order', location:location, delivery_date:Date.parse('2016-03-02'))
  #
  #   Item.all.each do |item|
  #     OrderItem.create(item:item, quantity:5, unit_price:5, order:order)
  #   end
  #
  #   assert order.draft?
  #
  #   result = nil
  #   VCR.use_cassette('sales_orders/002') do
  #     result = SalesOrdersSyncer.new.sync_local(10.minutes.ago)
  #   end
  #
  #   order.reload
  #
  #   assert order.deleted?
  # end

end
