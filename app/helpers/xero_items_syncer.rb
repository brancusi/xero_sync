class XeroItemsSyncer < BaseXeroSyncer
  include XeroUtils

  def batch_save_records(records)
    begin
      if records.all? {|record| record.is_a? Xeroizer::Record::Item}
        xero_client.Item.save_records(records)
      end
    rescue => errors
      p "Error batch saving items: #{errors}"
    end
  end

  protected
    def search_xero_record_by_id (model)
      xero_client.Item.find(model.xero_id)
    end

    def query_models(timestamp)
      Item.where('updated_at > ?', timestamp)
    end

    def query_xero(predicate)
      xero_client.Item.all(predicate)
    end

    def search_xero_record_by_other (model)
      match = xero_client.Item.all(:where => {:code => model.name})
      match.present? ? match.first : nil
    end

    def update_xero_record (record, model)
      record.code = model.name
      record.description = model.description
      record.is_purchased = false
    end

    def create_xero_record (model)
      xero_client.Item.build(code:model.name)
    end

    def find_or_build_model_for_record(record)
      Item.find_by(xero_id:record.item_id) || Item.find_by(name:record.code) || Item.create(name:record.code)
    end

    def update_model_for_record(model, record)
      model.update_columns(
        xero_id:record.item_id,
        name:record.code,
        description:record.description,
        is_sold:Maybe(record.is_sold).truly?,
        is_purchased:Maybe(record.is_purchased).truly?
      )
    end
end
