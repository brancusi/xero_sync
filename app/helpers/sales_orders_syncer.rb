class SalesOrdersSyncer < BaseSyncer

  protected
    def find_record(xero_id)
      xero.Invoice.find(xero_id)
    end

    def find_record_by(model)
      xero.Invoice.first(:where => {:invoice_number => model.order_number})
    end

    def find_records(timestamp)
      xero.Invoice.all({:modified_since => timestamp})
    end

    def update_local_state(record, model)
      case record.status
      when 'DELETED'
        model.void!
      when 'VOIDED'
        model.void!
      end
    end

    def should_save_record? (record, model)
      !model.voided?
    end

    def update_record(record, model)
      record.invoice_number = model.order_number
      record.date = model.delivery_date
      record.due_date = model.delivery_date + model.location.company.terms
      record.status = 'AUTHORISED'
      record.type = 'ACCREC'

      record.build_contact(contact_id:model.location.xero_id, name:model.location.xero_name)

      record.line_items.clear
      model.order_items.each do | order_item |
        record.add_line_item(
          item_code:order_item.item.name,
          description:order_item.item.description,
          quantity:order_item.quantity,
          unit_amount:order_item.unit_price,
          tax_type:'NONE',
          account_code: '400')
      end
    end

    def create_record
      xero.Invoice.build
    end

    def save_records(records)
      xero.Invoice.save_records(records)
    end

    def find_model(record)
      Order.find_by(xero_id:record.invoice_id) || Order.find_by(order_number:record.invoice_number)
    end

    def find_models(timestamp)
      Order.where(order_state: 1)
    end

    def update_model(model, record)
      model.update_columns(xero_id:record.invoice_id)
      model.mark_synced!
    end
end
