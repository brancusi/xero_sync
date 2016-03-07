class LocationsSyncer < BaseSyncer

  protected
    def find_record(xero_id)
      xero.Contact.find(xero_id)
    end

    def find_record_by(model)
      xero.Contact.first(:where => {:name => model.xero_name})
    end

    def find_records(timestamp)
      xero.Contact.all({:modified_since => timestamp})
    end

    def update_record(record, model)
      record.name = model.xero_name
    end

    def create_record(model)
      xero.Contact.build(name:model.xero_name)
    end

    def save_records(records)
      xero.Contact.save_records(records)
    end

    def find_model(record)
      # Internally the location code is the unique key. For xero though we construct a name.
      # This is the reverse lookup of that local key. i.e. NW001 - Nature Well - Silverlake
      # gets split to NW001 as the local key.
      code = record.name.split(' ')[0]
      Location.find_by(xero_id:record.contact_id) || Location.find_by(code:code)
    end

    def find_models(timestamp)
      Location.where('updated_at > ?', timestamp)
    end

    def update_model(model, record)
      if record.name != model.xero_name
        warn "The remote xero name did not match the local value. This may be due to a user changing this contact in xero. Local name: #{model.xero_name} - Remote name: #{record.name}"
      end
      model.update_columns(xero_id:record.contact_id)
    end
end
