class XeroInvoicesSyncer < BaseXeroSyncer
  include XeroUtils

  def batch_save_records(records)
    xero_client.Invoice.save_records(records)
  end

  protected
    def search_xero_record_by_id (model)
      xero_client.Invoice.find(model.xero_id)
    end

    def search_xero_record_by_other (model)
      match = xero_client.Invoice.all(:where => {:invoice_number => "testing9-nov-2015-#{model.id}"})
      match.present? ? match.first : nil
    end

    def update_xero_record (record, model)
      record.invoice_number = "testing9-nov-2015-#{model.id}"
      record.date = model.delivery_date
      record.due_date = model.delivery_date + model.client.terms
      record.status = "SUBMITTED"
      record.type = "ACCREC"
      record.build_contact(contact_id:model.client.xero_id, name:model.client.full_name)
      create_sales_order_items(record, model)
    end

    def create_xero_record (model)
      update_xero_record(xero_client.Invoice.build(), model)
    end

    def create_sales_order_items (record, model)
      record.line_items.clear
      model.sales_order_items.each do | soi |
        record.add_line_item(
          item_code:soi.item.code,
          description:soi.item.description,
          quantity:soi.quantity,
          unit_amount:soi.unit_price,
          tax_type:'NONE',
          account_code: '3000')
      end

      return record
    end

    def update_model_for_record (record)
      invoice_number = record.invoice_number
      invoice_number.slice! "testing9-nov-2015-";
      model = SalesOrder.find(invoice_number.to_i)
      model.update_columns(xero_id:record.invoice_id)
    end
end
