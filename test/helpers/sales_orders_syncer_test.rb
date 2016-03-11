require 'test_helper'

class SalesOrdersSyncerTest < ActiveSupport::TestCase

  # Local sync testing
  test "Deleted orders should be remove from the system" do

    Item.create(name:'Sunseed Chorizo', xero_id:'b3d9696b-13f3-455a-aac9-c5b26e9b71ea')

    company = Company.create(name:'Nature Well')
    location = Location.create(name:'Silverlake', code:'NW001', company:company)
    order = Order.create(order_type:'sales-order', location:location, delivery_date:Date.parse('2016-03-01'))

    Item.all.each do |item|
      OrderItem.create(item:item, quantity:5, unit_price:5, order:order)
    end

    result = nil
    VCR.use_cassette('sales_orders/002') do
      result = SalesOrdersSyncer.new.sync_local(10.minutes.ago)
    end

    order.reload

    binding.pry

    assert order.xero_id.present?
    assert_equal(order.order_items.count, result.first.line_items.count)
    assert_equal(order.order_items.first.quantity, result.first.line_items.first.quantity)
    assert_equal(order.order_items.first.unit_price, result.first.line_items.first.unit_amount)
    assert_equal(order.order_items.first.unit_price * order.order_items.first.quantity, result.first.line_items.first.line_amount)
  end

  test "Should sync local sales_orders when they don't exist in xero" do

    Item.create(name:'Sunseed Chorizo', xero_id:'b3d9696b-13f3-455a-aac9-c5b26e9b71ea')

    company = Company.create(name:'Nature Well')
    location = Location.create(name:'Silverlake', code:'NW001', company:company)
    order = Order.create(order_type:'sales-order', location:location, delivery_date:Date.parse('2016-03-01'))

    Item.all.each do |item|
      OrderItem.create(item:item, quantity:5, unit_price:5, order:order)
    end

    result = nil
    VCR.use_cassette('sales_orders/002') do
      result = SalesOrdersSyncer.new.sync_local(10.minutes.ago)
    end

    order.reload

    binding.pry

    assert order.xero_id.present?
    assert_equal(order.order_items.count, result.first.line_items.count)
    assert_equal(order.order_items.first.quantity, result.first.line_items.first.quantity)
    assert_equal(order.order_items.first.unit_price, result.first.line_items.first.unit_amount)
    assert_equal(order.order_items.first.unit_price * order.order_items.first.quantity, result.first.line_items.first.line_amount)
  end

end
