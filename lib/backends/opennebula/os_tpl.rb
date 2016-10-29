module Backends
  module Opennebula
    module OsTpl
      OS_TPL_TERM_PREFIX = 'uuid'

      # Gets backend-specific `os_tpl` mixins which should be merged
      # into Occi::Model of the server.
      #
      # @example
      #    mixins = os_tpl_list #=> #<Occi::Core::Mixins>
      #    mixins.first #=> #<Occi::Core::Mixin>
      #
      # @return [Occi::Core::Mixins] a collection of mixins
      def os_tpl_list
        os_tpl = Occi::Core::Mixins.new
        backend_tpl_pool = ::OpenNebula::TemplatePool.new(@client)
        rc = backend_tpl_pool.info_all
        check_retval(rc, Backends::Errors::ResourceRetrievalError)

        backend_tpl_pool.each do |backend_tpl|
          depends = %w|http://schemas.ogf.org/occi/infrastructure#os_tpl|
          term = os_tpl_list_tpl_to_term(backend_tpl)
          scheme = "#{@options.backend_scheme}/occi/infrastructure/os_tpl#"
          title = backend_tpl['NAME']
          location = "/mixin/os_tpl/#{term}/"
          applies = %w|http://schemas.ogf.org/occi/infrastructure#compute|

          os_tpl << Occi::Core::Mixin.new(scheme, term, title, nil, depends, nil, location, applies)
        end

        os_tpl
      end

      # Gets a specific os_tpl mixin instance as Occi::Core::Mixin.
      # Term given as an argument must match the term inside
      # the returned Occi::Core::Mixin instance.
      #
      # @example
      #    os_tpl = os_tpl_get('65d4f65adfadf-ad2f4ad-daf5ad-f5ad4fad4ffdf')
      #        #=> #<Occi::Core::Mixin>
      #
      # @param term [String] OCCI term of the requested os_tpl mixin instance
      # @return [Occi::Core::Mixin, nil] a mixin instance or `nil`
      def os_tpl_get(term)
        # TODO: make it more efficient!
        os_tpl_list.to_a.select { |m| m.term == term }.first
      end
      

      def os_tpl_trigger_action(os_tpl_id, action_instance)
        
#=begin
        case action_instance.action.type_identifier
        when 'http://schemas.ogf.org/occi/infrastructure/os_tpl/action#clone'
          #storage_trigger_action_online(storage_id, action_instance.attributes)
        
          os_tpl = ::OpenNebula::Template.new( ::OpenNebula::Template.build_xml(os_tpl_id), @client )
          rc = os_tpl.info
          check_retval(rc, Backends::Errors::ResourceRetrievalError)
        
          #clone action
          ##{DateTime.now.to_s.gsub(':', '_')}
          #rc = os_tpl.clone( "ubunt-occi-hd-4G-px" )
          rc = os_tpl.clone( "tmp-os_tpl-#{DateTime.now.to_s.gsub(':', '_')}" )
          check_retval(rc, Backends::Errors::ResourceActionError)
          
        when 'http://schemas.ogf.org/occi/infrastructure/os_tpl/action#update'
          #storage_trigger_action_offline(storage_id, action_instance.attributes)
          
          os_tpl = ::OpenNebula::Template.new( ::OpenNebula::Template.build_xml(os_tpl_id), @client )
          rc = os_tpl.info
          check_retval(rc, Backends::Errors::ResourceRetrievalError)
        
          #clone action
          new_img_id = action_instance.attributes.occi.infrastructure.os_tpl.image_id
          update_xml = " DISK = [ IMAGE_ID = #{new_img_id} ]"
          rc = os_tpl.update( update_xml, true )
          puts "daniel: result of os_tpl.update: " + rc.inspect
          check_retval(rc, Backends::Errors::ResourceActionError)
          
        when 'http://schemas.ogf.org/occi/infrastructure/os_tpl/action#instantiate'
          #storage_trigger_action_backup(storage_id, action_instance.attributes)
          
          os_tpl = ::OpenNebula::Template.new( ::OpenNebula::Template.build_xml(os_tpl_id), @client )
          rc = os_tpl.info
          check_retval(rc, Backends::Errors::ResourceRetrievalError)
        
          #clone action
          rc = os_tpl.instantiate( "tmp-vm-#{DateTime.now.to_s.gsub(':', '_')}" )
          check_retval(rc, Backends::Errors::ResourceActionError)
          
        else
          fail Backends::Errors::ActionNotImplementedError,
               "Action #{action_instance.action.type_identifier.inspect} is not implemented!"
        end

#=end
        
        true
        
      end
      

      private

      def os_tpl_list_tpl_to_term(tpl)
        fixed = tpl['NAME'].downcase.gsub(/[^0-9a-z]/i, '_')
        fixed = fixed.gsub(/_+/, '_').chomp('_').reverse.chomp('_').reverse
        "#{OS_TPL_TERM_PREFIX}_#{fixed}_#{tpl['ID']}"
      end

      def os_tpl_list_term_to_id(term)
        matched = term.match(/^.+_(?<id>\d+)$/)

        fail Backends::Errors::IdentifierNotValidError,
             "OsTpl term is invalid! #{term.inspect}" unless matched

        matched[:id].to_i
      end
    end
  end
end
