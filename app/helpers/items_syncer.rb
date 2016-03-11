class ItemsSyncer < BaseSyncer

  protected
    def find_record(xero_id)
      xero.Item.find(xero_id)
    end

    def find_record_by(model)
      xero.Item.first(:where => {:code => model.name})
    end

    def find_records(timestamp)
      xero.Item.all({:modified_since => timestamp})
    end

    def update_record(record, model)
      record.code = model.name
      record.description = model.description
      record.is_purchased = model.is_purchased
      record.is_sold = model.is_sold
    end

    def create_record
      xero.Item.build
    end

    def save_records(records)
      xero.Item.save_records(records)
    end

    def find_model(record)
      Item.find_by(xero_id:record.item_id) || Item.find_by(name:record.code)
    end

    def find_models(timestamp)
      Item.where('updated_at > ?', timestamp)
    end

    def update_model(model, record)
      model.update_columns(
        xero_id:record.item_id,
        name:record.code,
        description:record.description,
        is_sold:Maybe(record.is_sold).truly?,
        is_purchased:Maybe(record.is_purchased).truly?
      )
    end
end
