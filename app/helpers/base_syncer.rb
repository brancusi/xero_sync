class BaseSyncer
  include XeroUtils
  include RedisUtils

  # Sync from local to xero
  def sync_local(timestamp = fetch_last_local_sync(self))
    start_timestamp = DateTime.now
    result = process_local(find_models(timestamp))

    if result
      set_last_local_sync(self, start_timestamp)
    end

    return result
  end

  # Sync from xero to local
  def sync_remote(timestamp = fetch_last_remote_sync(self))
    start_timestamp = DateTime.now

    result = process_records(find_records(timestamp))

    if result
      set_last_remote_sync(self, start_timestamp)
    end

    return result
  end

  protected
    # Try to find a single xero record by its xero id
    def find_record(xero_id)
      raise_must_override
    end

    # Try to find a single record by some other predicate
    # Each record type may need a slightly different lookup
    def find_record_by(model)
      raise_must_override
    end

    # Query for a specific type of record using a predicate
    def find_records(predicate)
      raise_must_override
    end

    # Update a record based on the diff with the local model
    def update_record(record, model)
      raise_must_override
    end

    # Create a new xero record. This is called when the find_xero methods
    # return nil
    def create_record(model)
      raise_must_override
    end

    # OPTIONAL - Check if this record should be deleted
    def should_delete?(record)
      false
    end

    # Responsible for finding the local model for this record
    # It is up to the subclass to determine lookup logic
    # or to create a new model if none is found.
    # If nil is returned, the task won't attempt to process the record
    def find_model(record)
      raise_must_override
    end

    # Query local models based on last_updated timestamp
    def find_models(timestamp)
      raise_must_override
    end

    # Update the local model based on the record
    def update_model(record)
      raise_must_override
    end

    # Batch save xero record
    def save_records(records)
      raise_must_override
    end

    def log(message, level = 'info')
      Rails.logger.info("[Syncer - #{self.class} - #{level}]: #{message}")
    end

    def warn(message)
      log(message, 'warn')
    end

  private
    def raise_must_override
      raise 'You must override this method in the concrete module'
    end

    def process_local(models)
      records = models.map(&method(:prepare_record)).compact

      if records.present?
        if save_records(records)
          begin
            process_records(records)
          rescue => errors
            raise "Error processing records: #{records}"
          end
        else
          raise "Error batch saving"
        end
      end
    end

    def prepare_record(model)
      begin
        record = nil

        if model.xero_id.present?
          begin
            record = find_record(model.xero_id)
          rescue => errors
            p "Error finding a record with that id: #{errors}"
          end
        end

        if record.nil?
          begin
            record = find_record_by(model)
          rescue => errors
            p "Error finding record with that search criteria: #{errors}"
          end
        end

        if record.present?
          if should_delete? record
            model.destroy
            return nil
          else
            update_record(record, model)
            return record
          end
        else
          create_record(model)
        end
      rescue => errors
        p "There was an error preparing this model: #{errors}"
      end
    end

    def process_records(records)
      records.map {|record|
        begin
          update_model(find_model(record), record)
          record
        rescue => errors
          p "There was an error processing this record: #{errors}"
          nil
        end
      }.compact
    end
end
