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

module Backends::Opennebula::Authn::CloudAuth
  module BasicCloudAuth
    def do_auth(params = {})
      
      #set for test
      params = {}
      params[:username] = "rocci"
      params[:password] = "rocci"
      
      fail Backends::Errors::AuthenticationError, 'Credentials for Basic not set!' unless params && params[:username] && params[:password]

      #one_pass = get_password(params[:username], 'core')
      one_pass = get_password(params[:username], 'server_cipher')
      t = Time.now
      File.open("/opt/ISSC/daniel.log", "a+") { |f| f.puts t.strftime("%H:%M:%S:%L") + " [daniel] Backends::Opennebula::Authn::CloudAuth::BasicCloudAuth.do_auth(), one_pass: " + one_pass.inspect + ". " }
      return nil if one_pass.blank?
      File.open("/opt/ISSC/daniel.log", "a+") { |f| f.puts t.strftime("%H:%M:%S:%L") + " [daniel] Backends::Opennebula::Authn::CloudAuth::BasicCloudAuth.do_auth(), ::Digest::SHA1.hexdigest: " + ::Digest::SHA1.hexdigest(params[:password]).inspect + ". " }
      return nil unless one_pass == ::Digest::SHA1.hexdigest(params[:password])

      params[:username]
    end
  end
end
