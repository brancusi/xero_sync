class XeroContactsSyncer < BaseXeroSyncer
  include XeroUtils

  def batch_save_records(records)
    begin
      if records.all? {|record| record.is_a? Xeroizer::Record::Contact}
        xero_client.Contact.save_records(records)
      end
    rescue => errors
      p "Error batch saving contacts: #{errors}"
    end
  end

  protected
    def search_xero_record_by_id (model)
      xero_client.Contact.find(model.xero_id)
    end

    def search_xero_record_by_other (model)
      match = xero_client.Contact.all(:where => {:name => model.full_name})
      match.present? ? match.first : nil
    end

    def update_xero_record (record, model)
      record.name = model.full_name
      record.contact_number = model.id
      return record
    end

    def create_xero_record (model)
      xero_client.Contact.build(name:model.full_name, contact_number:model.id)
    end

    def update_model_for_record (record)
      model = Location.find(record.contact_number)
      model.update_columns(xero_id:record.contact_id)
    end
end
