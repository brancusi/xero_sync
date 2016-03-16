require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  test "should generate an order_number after created" do
    Item.create(name:'Sunseed Chorizo')

    company = Company.create(name:'Nature Well')
    location = Location.create(name:'Silverlake', code:'NW001', company:company)
    order = Order.new(order_type:'sales-order', location:location, delivery_date:Date.parse('2016-03-01'))

    refute order.order_number.present?

    order.save

    assert order.order_number.present?
  end

  test "should generate an order_number that includes INV prefix" do

    total_orders = Order.all.count
    Item.create(name:'Sunseed Chorizo')

    company = Company.create(name:'Nature Well')
    location = Location.create(name:'Silverlake', code:'NW001', company:company)
    order = Order.new(order_type:'sales-order', location:location, delivery_date:Date.parse('2016-03-01'))
    refute order.order_number.present?

    order.save

    inv_reg = /INV-/
    assert_equal(0, order.order_number =~ inv_reg)
  end

  test "should only generate order_number once on create" do
    Item.create(name:'Sunseed Chorizo')

    company = Company.create(name:'Nature Well')
    location = Location.create(name:'Silverlake', code:'NW001', company:company)
    order = Order.new(order_type:'sales-order', location:location, delivery_date:Date.parse('2016-03-01'))

    order_spy = Spy.on(order, :generate_invoice_number)

    order.save

    order.delivery_date = Date.today + 2

    order.save

    assert order_spy.has_been_called?
    assert_equal 1, order_spy.calls.count
  end

  test "can transition from pending to fulfilled" do
    Item.create(name:'Sunseed Chorizo')

    company = Company.create(name:'Nature Well')
    location = Location.create(name:'Silverlake', code:'NW001', company:company)
    order = Order.create(order_type:'sales-order', location:location, delivery_date:Date.parse('2016-03-01'))

    assert order.pending?
    order.mark_fulfilled!
    assert order.fulfilled?
  end

  test "can void pending orders" do
    Item.create(name:'Sunseed Chorizo')

    company = Company.create(name:'Nature Well')
    location = Location.create(name:'Silverlake', code:'NW001', company:company)
    order = Order.create(order_type:'sales-order', location:location, delivery_date:Date.parse('2016-03-01'))

    assert order.pending?
    order.void!
    assert order.voided?
  end

  test "can void fulfilled orders" do
    Item.create(name:'Sunseed Chorizo')

    company = Company.create(name:'Nature Well')
    location = Location.create(name:'Silverlake', code:'NW001', company:company)
    order = Order.create(order_type:'sales-order', location:location, delivery_date:Date.parse('2016-03-01'))

    assert order.pending?

    order.mark_fulfilled!

    assert order.fulfilled?

    order.void!

    assert order.voided?
  end

end
