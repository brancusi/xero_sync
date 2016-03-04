class BaseXeroSyncer

  # Sync from local to xero
  def sync_local(timestamp)
    models = query_models(timestamp)
    process_sync_request(models)
  end

  # Sync from xero to local
  def sync_remote(timestamp)
    records = query_xero({:modified_since => timestamp})
    process_reponse(records)
  end

  def batch_save_records(records)
    raise 'You must override this method in the concrete module'
  end

  protected
    def search_xero_record_by_id(model)
      raise_must_override
    end

    def query_models(timestamp)
      raise_must_override
    end

    def query_xero(predicate)
      raise_must_override
    end

    def search_xero_record_by_other(model)
      raise_must_override
    end

    def update_xero_record(record, model)
      raise_must_override
    end

    def create_xero_record(model)
      raise_must_override
    end

    def find_or_build_model_for_record(record)
      raise_must_override
    end

    def update_model_for_record(record)
      raise_must_override
    end

  private
    def raise_must_override
      raise 'You must override this method in the concrete module'
    end

    def process_sync_request(models)
      records = build_record_collection(models)
      p records
      if records.present?
        if batch_save_records(records)
          process_reponse(records)
        else
          p 'Error batch saving!'
        end

      end
    end

    def build_record_collection(models)
      models.map {|model|
        prepare_record_for_model(model)
      }.compact
    end

    def prepare_record_for_model(model)
      record = nil

      begin
        record =(search_xero_record_by_id(model) if model.xero_id.present?)
      rescue => errors
        p "Resource not found with that xero_id: #{errors}"
      end

      if record.nil?
        begin
          record = search_xero_record_by_other(model)
        rescue => errors
          p "Resource not found with that search criteria: #{errors}"
        end
      end

      if record.present?
        begin
          update_xero_record(record, model)

          return record
        rescue => errors
          p "Failed to update record: #{errors}"
        end
      else
        create_xero_record(model)
      end
    end

    def process_reponse(records)
      records.each do |record|
        begin
          model = find_or_build_model_for_record(record)
          update_model_for_record(model, record)
        rescue => errors
          p "There was an error saving this model: #{errors}"
        end
      end
    end

end
