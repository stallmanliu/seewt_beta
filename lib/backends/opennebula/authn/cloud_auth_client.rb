# -------------------------------------------------------------------------- #
# Copyright 2002-2013, OpenNebula Project (OpenNebula.org), C12G Labs        #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

require 'thread'

module Backends::Opennebula::Authn
  class CloudAuthClient
    # These are the authentication methods for the user requests
    AUTH_MODULES = {
        'basic'   => 'BasicCloudAuth',
        'digest'  => 'BasicCloudAuth',
        'x509'    => 'X509CloudAuth',
        'voms'    => 'VomsCloudAuth'
    }

    # These are the authentication modules for the OpenNebula requests
    # Each entry is an array with the filename  for require and class name
    # to instantiate the object.
    AUTH_CORE_MODULES = {
       'cipher' => 'ServerCipherAuth'
    }

    # Default interval for timestamps. Tokens will be generated using the same
    # timestamp for this interval of time.
    # THIS VALUE CANNOT BE LOWER THAN EXPIRE_MARGIN
    EXPIRE_DELTA = 1800

    # Tokens will be generated if time > EXPIRE_TIME - EXPIRE_MARGIN
    EXPIRE_MARGIN = 300

    # The user pool will be updated every EXPIRE_USER_CACHE seconds.
    EXPIRE_USER_CACHE = 60

    # conf a hash with the configuration attributes as symbols
    def initialize(conf)
      @conf   = conf
      
      #set for test
      @conf[:auth] = "basic"
      
      @lock   = ::Mutex.new
      @token_expiration_time = ::Time.now.to_i + EXPIRE_DELTA
      @upool_expiration_time = 0
      @conf[:use_user_pool_cache] = true

      if AUTH_MODULES.include?(@conf[:auth])
        extend Backends::Opennebula::Authn::CloudAuth.const_get(AUTH_MODULES[@conf[:auth]])
        self.class.initialize_auth if self.class.method_defined?(:initialize_auth)
      else
        fail Backends::Errors::AuthenticationError, 'Auth module not specified'
      end

      # TODO: support other core authN methods than server_cipher
      core_auth = AUTH_CORE_MODULES[conf[:srv_auth]]
      begin
        @server_auth = Backends::Opennebula::Authn::CloudAuth.const_get(core_auth).new(@conf[:srv_user], @conf[:srv_passwd])
      rescue => e
        raise Backends::Errors::AuthenticationError, e.message
      end
    end

    # Generate a new OpenNebula client for the target User, if the username
    # is nil the Client is generated for the server_admin
    # username:: _String_ Name of the User
    # [return] _Client_
    def client(username = nil)
      expiration_time = @lock.synchronize do
        time_now = ::Time.now.to_i

        if time_now > @token_expiration_time - EXPIRE_MARGIN
            @token_expiration_time = time_now + EXPIRE_DELTA
        end

        @token_expiration_time
      end

      token = @server_auth.login_token(expiration_time, username)

      ::OpenNebula::Client.new(token, @conf[:one_xmlrpc])
    end

    # Authenticate the request. This is a wrapper method that executes the
    # specific do_auth module method. It updates the user cache (if needed)
    # before calling the do_auth module.
    def auth(params = {})
      update_userpool_cache if @conf[:use_user_pool_cache]
      do_auth(params)
    end

    protected

    # Gets the password associated with a username
    # username:: _String_ the username
    # driver:: _String_ list of valid drivers for the user, | separated
    # [return] _Hash_ with the username
    def get_password(username, driver = nil)
      begin
        username = username.encode(xml: :text)
      rescue
        return nil
      end

      xpath = "USER[NAME=\"#{username}\""
      if driver
        xpath << " and (AUTH_DRIVER=\""
        xpath << driver.split('|').join("\" or AUTH_DRIVER=\"") << '")'
      end
      xpath << ']/PASSWORD'

      retrieve_from_userpool(xpath)
    end

    # Gets the username associated with a password
    # password:: _String_ the password
    # [return] _Hash_ with the username
    def get_username(password)
      # Trying to match password with each
      # of the pipe-separated DNs stored in USER/PASSWORD
      @lock.synchronize do
        @user_pool.each_with_xpath("USER[contains(PASSWORD, \"#{password}\")]") do |user|
          return user['NAME'] if user['AUTH_DRIVER'] == 'x509' && user['PASSWORD'].split('|').include?(password)
        end
      end

      nil
    end

    private

    def retrieve_from_userpool(xpath)
      @lock.synchronize { @user_pool[xpath] }
    end

    # Updates the userpool cache every EXPIRE_USER_CACHE seconds.
    # The expiration time is updated if the cache is successfully updated.
    def update_userpool_cache
      oneadmin_client = client

      @lock.synchronize do
        if ::Time.now.to_i > @upool_expiration_time
          @user_pool = ::OpenNebula::UserPool.new(oneadmin_client)

          rc = @user_pool.info
          fail Backends::Errors::AuthenticationError, rc.message if ::OpenNebula.is_error?(rc)

          @upool_expiration_time = ::Time.now.to_i + EXPIRE_USER_CACHE
        end
      end
    end
  end
end
