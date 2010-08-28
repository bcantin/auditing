module Auditing

  # Auditing creates audit objects for a record.
  # @examples
  #   class School < ActiveRecord::Base
  #      auditing
  #   end
  #   class School < ActiveRecord::Base
  #     auditing :fields => [:name, :established_on]
  #   end
  def auditing(opts={})
    class_inheritable_accessor :auditing_fields

    self.auditing_fields = gather_fields_for_auditing(opts[:fields])
  end

  def gather_fields_for_auditing(fields=nil)
    return self.column_names - ["id", "created_at", "updated_at"] unless fields
    fields.is_a?(Array) ? fields.map {|f| f.to_s} : [fields.to_s]
  end

end
