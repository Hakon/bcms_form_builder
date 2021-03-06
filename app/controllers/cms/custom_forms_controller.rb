class Cms::CustomFormsController < Cms::ContentBlockController
  
  # new_element_partial
  #
  # Renders the partial for a new CustomFormElement.  Gives the item a unique index
  # based on the session[:form_builder] hash, which keeps a counter of the last
  # index.  NOTE: this counter is reset by each page render of a new CustomForm
  # new/edit form.
  #
  def new_element_partial
    unless params[:type] && (klass = CustomFormElement.subclass(params[:type]))
      render :nothing => true, :status => 404
      return
    end
    
    params[:position] ||= 0
    
    element = klass.new
    element.position = params[:position]
    index = (session[:form_builder] ||= {:element_index => 0})[:element_index].to_i + 1
    session[:form_builder][:element_index] += 1
    
    render :partial => "cms/custom_forms/forms/#{klass.config.name}_element", :locals => {:index => "new_#{index}", :element => element}
  end

  # Superceded by custom_form_elements_controller
#  def new_element
#    unless params[:type] && (klass = CustomFormElement.subclass(params[:type]))
#      redirect_to cms_custom_forms_url
#      return
#    end
#
#    begin
#      @form = CustomForm.find(params[:form_id])
#    rescue ActiveRecord::RecordNotFound
#      redirect_to cms_custom_forms_url
#      return
#    end
#
#    element = klass.new
#    @toolbar_title = "#{klass.config.display_name} for '#{@form.name}' custom form"
#
#    unless request.post?
#      render :template => "cms/custom_forms/forms/#{klass.config.name}_element", :locals => {:element => element}
#      return
#    end
#  end

  # order_elements
  #
  # Reassign position attribute for each element in params[:element_list_order].
  # Always return success.
  #
  def order_elements
    load_block

    @block.reorder_elements!(params[:element_list_order]) if params[:element_list_order].is_a?(Array)

    render :nothing => true, :code => 200
  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :code => 200
  end

  protected

    def check_permissions
      case action_name
      when 'edit_elements', 'order_elements'
        raise Cms::Errors::AccessDenied unless current_user.able_to_edit?(@block)
      else
        super
      end
    end

end
