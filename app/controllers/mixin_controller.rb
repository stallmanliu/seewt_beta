# Controller class handling all mixin-related requests.
# Implements listing, assignment, creation, deletion and
# triggering actions on mixin-tagged instances.
#
# `os_tpl` and `resource_tpl` mixins are a special case and
# are handled separately. See OsTplController and ResourceTplController.
#
# TODO: Not yet implemented! Returns HTTP 501 for all requests!
class MixinController < ApplicationController
  # GET /mixin/:term*/
  def index
    # TODO: impl
    @resources = Occi::Collection.new
    respond_with(@resources, status: 501)
  end

  # POST /mixin/:term*/?action=:action
  def trigger
    # TODO: impl
    
=begin
    ai = request_occi_collection(Occi::Core::ActionInstance).action
    check_ai!(ai, request.query_string)

    if params[:id]
      result = backend_instance.mixin_trigger_action(params[:id], ai)
    else
      result = backend_instance.mixin_trigger_action_on_all(ai)
    end

    if result
      respond_with(Occi::Collection.new)
    else
      respond_with(Occi::Collection.new, status: 304)
    end
=end
    
    collection = Occi::Collection.new
    respond_with(collection, status: 501)
  end

  # POST /mixin/:term*/
  def assign
    # TODO: impl
    collection = Occi::Collection.new
    respond_with(collection, status: 501)
  end

  # PUT /mixin/:term*/
  def update
    # TODO: impl
    collection = Occi::Collection.new
    respond_with(collection, status: 501)
  end

  # DELETE /mixin/:term*/
  def delete
    # TODO: impl
    collection = Occi::Collection.new
    respond_with(collection, status: 501)
  end
end
