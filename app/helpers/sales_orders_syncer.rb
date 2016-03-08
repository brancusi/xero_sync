class SalesOrdersSyncer < BaseSyncer

  protected
    def find_record(xero_id)
      xero.Invoice.find(xero_id)
    end

    def find_record_by(model)
      xero.Invoice.first(:where => {:invoice_number => model.xero_invoice_number})
    end

    def find_records(timestamp)
      xero.Invoice.all({:modified_since => timestamp})
    end

    def should_delete?(record)
      record.status == 'DELETED'
    end

    def update_record(record, model)
      record.invoice_number = model.xero_invoice_number
      record.date = model.delivery_date
      record.due_date = model.delivery_date + model.location.company.terms
      record.status = "DRAFT"
      record.type = "ACCREC"
      record.build_contact(contact_id:model.location.xero_id, name:model.location.xero_name)
      create_order_items(record, model)

      record.line_items.clear
      model.order_items.each do | order_item |
        record.add_line_item(
          item_code:order_item.item.name,
          description:order_item.item.description,
          quantity:order_item.quantity,
          unit_amount:model.price_for_item(order_item.item),
          tax_type:'NONE',
          account_code: '400')
      end
    end

    def create_record(model)
      xero.Invoice.build(invoice_number:model.xero_invoice_number)
    end

    def save_records(records)
      xero.Invoice.save_records(records)
    end

    def find_model(record)
      # Internally the location code is the unique key. For xero though we construct a name.
      # This is the reverse lookup of that local key. i.e. NW001 - Nature Well - Silverlake
      # gets split to NW001 as the local key.
      code = record.name.split(' ')[0]
      Order.find_by(xero_id:record.contact_id) || Order.find_by(code:code)
    end

    def find_models(timestamp)
      Order.where('updated_at > ?', timestamp)
    end

    def update_model(model, record)
      if record.name != model.xero_name
        warn "The remote xero name did not match the local value. This may be due to a user changing this contact in xero. Local name: #{model.xero_name} - Remote name: #{record.name}"
      end
      model.update_columns(xero_id:record.contact_id)
    end
end
