module InheritedResources
  module Actions

    # GET /resources/1/delete
    def delete(options={}, &block)
      respond_with(*(with_chain(resource) << options), &block)
    end
    alias :delete! :delete

    # DELETE /resources/1
    def destroy(options={}, &block)
      object = resource
      options[:location] ||= collection_url rescue nil
      redirect_to(object) and return if params[:cancel]
      
      destroy_resource(object)
      respond_with_dual_blocks(object, options, &block)
    end

    # Make aliases protected
    protected :delete!
  end
end