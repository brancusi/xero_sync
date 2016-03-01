class BaseXeroSyncer

  def sync (models)
    process_sync_request(models)
  end

  def batch_save_records (records)
    raise 'You must override this method in the concrete module'
  end

  protected
    def search_xero_record_by_id (model)
      raise 'You must override this method in the concrete module'
    end

    def search_xero_record_by_other (model)
      raise 'You must override this method in the concrete module'
    end

    def update_xero_record (record, model)
      raise 'You must override this method in the concrete module'
    end

    def create_xero_record (model)
      raise 'You must override this method in the concrete module'
    end

    def update_model_for_record (record)
      raise 'You must override this method in the concrete module'
    end

  private
    def process_sync_request(models)
      records = build_record_collection(models)
      if records.present?

        if batch_save_records(records)
          process_reponse(records)
        else
          p 'Error batch saving!'
        end

      end
    end

    def build_record_collection (models)
      models.map {|model|
        prepare_record_for_model(model)
      }.compact
    end

    def prepare_record_for_model (model)
      record = nil

      begin
        record = (search_xero_record_by_id(model) if model.xero_id.present?)
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
        update_xero_record(record, model)
      else
        create_xero_record(model)
      end
    end

    def process_reponse (records)
      records.each do |record|
        begin
          model = update_model_for_record(record)
        rescue => errors
          p "There was an error saving this model: #{errors}"
        end
      end
    end

end
