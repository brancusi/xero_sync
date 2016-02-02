module SyncSalesOrdersHelper
  include XeroUtils

  def sync_sales_orders
    xero = create_xero_client

    sales_orders = SalesOrder.where(synced:false)

    xero_invoices = sales_orders.map {|so|
      process_sales_order(so, xero)
    }

    xero.Invoice.save_records(xero_invoices)

    process_reponse(xero_invoices)
  end

  def process_sales_order (sales_order, xero)
    if(sales_order.xero_id.present?)
      update_xero_invoice(sales_order, xero)
    else
      create_xero_invoice(sales_order, xero)
    end
  end

  def create_xero_invoice (sales_order, xero)
    p 'Creating'
    xero_invoice = xero.Invoice.create(
      invoice_number:"mlvk-#{sales_order.id}",
      date:sales_order.delivery_date,
      type:"ACCREC",
      due_date:Date.today + sales_order.client.terms,
      status:"SUBMITTED")
    xero_invoice.build_contact(contact_id:sales_order.client.xero_id, name:sales_order.client.full_name)

    create_invoice_items(xero_invoice, sales_order)

    xero_invoice
  end

  def update_xero_invoice (sales_order, xero)
    match = nil

    begin
      match = xero.Invoice.find(sales_order.xero_id) if sales_order.xero_id.present?
    rescue
      puts "Contact not found matching #{sales_order.xero_id}"
    end

    if match.present?
      puts 'found one updating'
      create_invoice_items(match, sales_order)

      return match
    else
      create_xero_invoice(sales_order, xero)
    end
  end

  def create_invoice_items (invoice, sales_order)
    invoice.line_items = [];
    sales_order.sales_order_items.each do | soi |
      invoice.add_line_item(
        item_code:soi.item.code,
        description:soi.item.description,
        quantity:soi.quantity,
        unit_amount:10,
        tax_type:'NONE',
        account_code: '3000')
    end
  end

  def process_reponse (xero_invoices)
    xero_invoices.each do |xi|
      if xi.errors.present?
        p 'Error foo!'
      else
        id = xi.invoice_number.split('-')[1]
        so = SalesOrder.find(id)
        so.xero_id = xi.invoice_id
        so.save
      end
    end
  end

end
