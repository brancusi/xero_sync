class XeroItemsSyncer < BaseXeroSyncer
  include XeroUtils

  def batch_save_records(records)
    xero_client.Item.save_records(records)
  end

  protected
    def search_xero_record_by_id (model)
      xero_client.Item.find(model.xero_id)
    end

    def search_xero_record_by_other (model)
      match = xero_client.Item.all(:where => {:code => model.name})
      match.present? ? match.first : nil
    end

    def update_xero_record (record, model)
      record.code = model.name
    end

    def create_xero_record (model)
      xero_client.Item.build(code:model.name)
    end

    def update_model_for_record (record)
      model = Item.find_by(name:record.code)
      model.update_columns(xero_id:record.item_id, name:record.code)
    end
end
