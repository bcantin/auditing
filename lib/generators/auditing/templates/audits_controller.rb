class AuditsController < ApplicationController

  def index
    resource  = params[:resource].classify.constantize
    @resource = resource.find(params[:id])
    @audits   = @resource.audits
  end
  
  def rollback
    audit = Audit.find(params[:id])
    audit.rollback
    
    resource = audit.auditable
    redirect_to audits_path(resource.class.table_name, resource)
  end

end
