module AuditsHelper

  def description(audit)
    str = case audit.action
    when 'created'
      "Created Record #{audit.auditable_type}"
    when 'updated'
      if audit.association.blank?
        if audit.field_name.match(/_id$/)
          "Old: #{get_belongs_to(audit, audit.old_value)} <br/>" +
          "New: #{get_belongs_to(audit, audit.new_value)}"
        else
          "Old: #{audit.old_value} <br/>" +
          "New: #{audit.new_value}"
        end
      else
        if audit.old_value
          "Old: #{get_has_many(audit, audit.old_value)}<br/>"+
          "New: #{get_has_many(audit, audit.new_value)}"
        else
          "New: #{get_has_many(audit, audit.new_value)}"
        end
      end
    when 'added'
      if audit.old_value
        "Old: #{get_has_many(audit, audit.old_value)}<br/>"+
        "New: #{get_has_many(audit, audit.new_value)}"
      else
        "New: #{get_has_many(audit, audit.new_value)}"
      end
    when 'removed'
      "Removed #{audit.association_type}"
    end
    
    str.html_safe
  end

  def get_has_many(audit, value)
    return nil unless value
    if audit.field_name.match(/_id$/)
      get_belongs_to(audit, value)
    else
      value
    end
  end

  ##
  # For a belongs_to association, we only store the ID of what is being
  # refered to (:industry_id => 5).  We cannot guess what would be relevant
  # to actually show for the value.  We recommend implementing a #to_label
  # method and/or overriding this method to display what is relevant to
  # your application.
  #
  # EG:
  #   class Industry < ActiveRecord::Base
  #     has_many :companies
  #
  #     def to_label
  #       name
  #     end
  #   end

  def get_belongs_to(audit, value)
    return nil unless value
    if audit.association
      klass = audit.association.class.reflect_on_association(audit.field_name.gsub(/_id$/,'').to_sym).class_name.constantize
    else
      klass = audit.auditable.class.reflect_on_association(audit.field_name.gsub(/_id$/,'').to_sym).class_name.constantize
    end
    value = klass.where(:id => value).first
    return 'Unknown' unless value
    return value.to_label
  end

end
