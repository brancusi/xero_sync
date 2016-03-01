class XeroInvoicesSyncer < BaseXeroSyncer
  include XeroUtils

  def batch_save_records(records)
    begin
      xero_client.Invoice.save_records(records)
    rescue => errors
      p "Error batch saving: #{errors}"
    end
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
      p 'updating'
      if record.status == 'DELETED'
        delete_order(model)
        return nil
      else
        record.invoice_number = "testing9-nov-2015-#{model.id}"
        record.date = model.delivery_date
        record.due_date = model.delivery_date + model.location.company.terms
        record.status = "DRAFT"
        record.type = "ACCREC"
        record.build_contact(contact_id:model.location.xero_id, name:model.location.full_name)
        create_order_items(record, model)
      end
    end

    def create_xero_record (model)
      p 'creating'
      update_xero_record(xero_client.Invoice.build(), model)
    end

    def delete_order (model)
      p 'will delete order'
    end

    def create_order_items (record, model)
      record.line_items.clear
      model.order_items.each do | order_item |
        record.add_line_item(
          item_code:order_item.item.name,
          description:order_item.item.description,
          quantity:order_item.quantity,
          unit_amount:model.price_for_item(order_item.item),
          tax_type:'NONE',
          account_code: '3000')
      end

      return record
    end

    def update_model_for_record (record)
      binding.pry
      invoice_number = record.invoice_number
      invoice_number.slice! "testing9-nov-2015-";
      model = Order.find(invoice_number.to_i)
      model.update_columns(xero_id:record.invoice_id)
    end
end
