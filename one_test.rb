#!/usr/bin/env ruby

#require 'rubygems'
require 'occi-api'
#require 'pp'

## options
use_os_temlate = true         # use OS_TEMPLATE or NETWORK + STORAGE + INSTANCE TYPE
OS_TEMPLATE    = 'monitoring' # name of the VM template in ON

clean_up_compute = true       # issue DELETE <RESOURCE> after we are done

USER_CERT          = ENV['HOME'] + '/.globus/usercred.pem'
USER_CERT_PASSWORD = 'mypassphrase'
CA_PATH            = '/etc/grid-security/certificates'

ONE_ENDPOINT           = 'https://172.90.0.10:11443'
ONE_USERNAME = 'rocci'
ONE_PASSWORD = 'rocci'

EC2_ENDPOINT           = 'https://172.90.0.20:11443'
#need specify AWS Access Key
EC2_USERNAME = ''
EC2_PASSWORD = ''
@@vm_num = 2


OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

def init_clients()
  #@one_client = init_client( "one" )
  init_client( "one" )
  #@ec2_client = init_client( "ec2" )
  init_client( "ec2" )
end

def prep_conn( connect_type )
  
  case connect_type
    
  when "one"
    
    if nil == @one_client
      puts "nil @one_client !"
      return
    end

    @one_client.class.base_uri( ONE_ENDPOINT )
    @one_client.class.basic_auth( ONE_USERNAME, ONE_PASSWORD )
    
  when "ec2"
    
    if nil == @ec2_client
      puts "nil @@ec2_client !"
      return
    end

    @ec2_client.class.base_uri( EC2_ENDPOINT )
    @ec2_client.class.basic_auth( EC2_USERNAME, EC2_PASSWORD )
    
  else
    
    puts "wront client_type input !"
    
  end
  
  return
  
end

def init_client( client_type )
  
  #puts "client_type:" + client_type.inspect
  
  case client_type
    
  when "one"
    
    #puts "case: one"
    
    @one_client = Occi::Api::Client::ClientHttp.new({
      :endpoint => ONE_ENDPOINT,
      :auth => {
        :type               => "basic",
    #    :user_cert          => USER_CERT,
    #    :user_cert_password => USER_CERT_PASSWORD,
    #    :ca_path            => CA_PATH
        :username           => ONE_USERNAME,
        :password => ONE_PASSWORD
      },
      :log => {
        :out   => STDERR,
        :level => Occi::Api::Log::WARN
      }
    })
    
  when "ec2"
    
    #puts "case: ec2"
    
    @ec2_client = Occi::Api::Client::ClientHttp.new({
      :endpoint => EC2_ENDPOINT,
      :auth => {
        :type               => "basic",
    #    :user_cert          => USER_CERT,
    #    :user_cert_password => USER_CERT_PASSWORD,
    #    :ca_path            => CA_PATH
        :username           => EC2_USERNAME,
        :password => EC2_PASSWORD
      },
      :log => {
        :out   => STDERR,
        :level => Occi::Api::Log::WARN
      }
    })
    
  else
    
    #puts "wront client_type input !"
    #client = nil
    
  end
  
  #puts "client.endpoint:" + client.endpoint.inspect
  
  #client
  return
  
end

def show_resource_types()
  
  if nil == @one_client or nil == @ec2_client
    
    puts "nil client !"
    return
    
  end
  
  puts "\n\nListing all available resource types:"
  
  #puts "\n\nONE:\n\n"
  
  #t = Time.now
  #File.open("/opt/ISSC/daniel.log", "a+") { |f| f.puts t.strftime("%H:%M:%S:%L") + " [daniel] occi_model_controller.rb, OcciModelController.show(), enter: " } 
    
  @one_client.get_resource_types.each do |type|
  puts "\n#{type}"
  end
  
  puts "\n\nEC2:\n\n"
  
  @ec2_client.get_resource_types.each do |type|
  puts "\n#{type}"
  end
  
  puts "\n\n"
  
  return
      
end

def list_ec2()
  
  #puts "\n\nListing one_client:"
  #prep_conn( "one" )
  
  #puts "\n\nbefore delete:"
  #@one_client.describe( "compute" ).each do |type|
    #puts "\n#{type}"
    #end
  
  #puts "\n\ngo to delete:"
  #@one_client.delete( "https://172.90.0.10:11443/compute/57" )
  
  #puts "\n\nafter delete:"
  #@one_client.describe( "storage" ).each do |type|
    #puts "\n#{type}"
    #end
  
  puts "\n\nListing ec2_client, get_resource_types:"
  prep_conn( "ec2" )
  @ec2_client.get_resource_types().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing ec2_client, client.get_mixin_types:"
  #prep_conn( "ec2" )
  @ec2_client.get_mixin_types().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing ec2_client, client.get_entity_types:"
  #prep_conn( "ec2" )
  @ec2_client.get_entity_types().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing ec2_client, client.get_link_types:"
  #prep_conn( "ec2" )
  @ec2_client.get_link_types().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing ec2_client, describe:"
  prep_conn( "ec2" )
  @ec2_client.describe( "compute" ).each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing ec2_client, describe:"
  prep_conn( "ec2" )
  @ec2_client.describe( "storage" ).each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing ec2_client, describe:"
  prep_conn( "ec2" )
  @ec2_client.describe( "network" ).each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing ec2_client, get_mixins:"
  prep_conn( "ec2" )
  @ec2_client.get_mixins().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing ec2_client, get_link_type_identifiers:"
  prep_conn( "ec2" )
  @ec2_client.get_link_type_identifiers().each do |type|
    puts "\n#{type}"
  end
  
  
end

def list_one()
  
  #puts "\n\nListing one_client:"
  #prep_conn( "one" )
  
  #puts "\n\nbefore delete:"
  #@one_client.describe( "compute" ).each do |type|
    #puts "\n#{type}"
    #end
  
  #puts "\n\ngo to delete:"
  #@one_client.delete( "https://172.90.0.10:11443/compute/57" )
  
  #puts "\n\nafter delete:"
  #@one_client.describe( "storage" ).each do |type|
    #puts "\n#{type}"
    #end
  
  puts "\n\nListing @one_client, get_resource_types:"
  prep_conn( "one" )
  @one_client.get_resource_types().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing @one_client, client.get_mixin_types:"
  #prep_conn( "ec2" )
  @one_client.get_mixin_types().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing @one_client, client.get_entity_types:"
  #prep_conn( "ec2" )
  @one_client.get_entity_types().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing @one_client, client.get_link_types:"
  #prep_conn( "ec2" )
  @one_client.get_link_types().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing @one_client, describe:"
  #prep_conn( "ec2" )
  @one_client.describe( "compute" ).each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing @one_client, describe:"
  #prep_conn( "ec2" )
  @one_client.describe( "storage" ).each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing @one_client, describe:"
  #prep_conn( "ec2" )
  @one_client.describe( "network" ).each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing @one_client, get_mixins:"
  #prep_conn( "ec2" )
  @one_client.get_mixins().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing @one_client, get_link_type_identifiers:"
  #prep_conn( "ec2" )
  @one_client.get_link_type_identifiers().each do |type|
    puts "\n#{type}"
  end
  
  
end


def test_one()
  
  puts "\n\nListing one_client:"
  prep_conn( "one" )
  #puts @one_client.get_mixin_type_identifiers()
  #puts @one_client.list_mixin( "uuid_lab_occi_one_vm_template_p0_2" ).inspect
  #puts @one_client.get_action_type_identifiers().inspect
=begin
  #@one_client.list( "http://schemas.ogf.org/occi/infrastructure#os_tpl" ).each do |type|
  @one_client.list_mixins().each do |type|
    puts type.inspect
    puts "\n#{type}"
  end
=end
  
  #puts @one_client.list_mixin( "uuid_lab_occi_one_vm_template_p23_25" )
  #puts @one_client.get( "https://172.90.0.10:11443/storage/15" ).inspect
  
  #startaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/compute/action#', term='start', title='start compute instance'
  #startactioninstance = Occi::Core::ActionInstance.new startaction, nil
  #stopaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/compute/action#', term='stop', title='stop compute instance'
  #stopactioninstance = Occi::Core::ActionInstance.new stopaction, nil
  #
  #backupaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/storage/action#', term='backup', title='backup storage'
  #backupactioninstance = Occi::Core::ActionInstance.new backupaction, nil
  


  #http://schemas.ogf.org/occi/infrastructure/storage/action#backup
  
  #puts @one_client.trigger( "https://172.90.0.10:11443/compute/59", stopactioninstance ).inspect
  #puts @one_client.trigger( "https://172.90.0.10:11443/compute/59", startactioninstance ).inspect
  #puts @one_client.trigger( "https://172.90.0.10:11443/storage/1", backupactioninstance ).inspect

  #puts @one_client.trigger( "https://172.90.0.10:11443/storage/1", backupactioninstance ).inspect
  
  #puts @one_client.delete( "https://172.90.0.10:11443/storage/36" ).inspect
  
  #http://occi.172.90.0.10/occi/infrastructure/os_tpl#uuid_lab_occi_one_vm_template_p0_2
  
  #backupaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/os_tpl/action#', term='clone', title='clone os_tpl'
  #backupactioninstance = Occi::Core::ActionInstance.new backupaction, nil
  
  #puts @one_client.trigger( "https://172.90.0.10:11443/mixin/os_tpl/2", backupactioninstance ).inspect
  #puts @one_client.trigger( "/mixin/os_tpl/2", backupactioninstance ).inspect
  puts @one_client.list( "compute" ).inspect
  
end


def get_latest_compute_id
  prep_conn( "one" )
  #puts @one_client.list( "compute" ).inspect
  
  compute_num = 0
  begin
  compute_num = @one_client.list( "compute" ).length
  puts "compute_num:" + compute_num.inspect
  sleep 1
  end until @one_client.list( "compute" ).length == compute_num
  
  latest_id = @one_client.list( "compute" ).last.split("/").last.to_i
  #puts @one_client.list( "compute" ).inspect
end

def get_latest_storage_id
  prep_conn( "one" )
  #puts @one_client.list( "storage" ).inspect
  
  storage_num = 0
  begin
  storage_num = @one_client.list( "storage" ).length
  puts "storage_num:" + storage_num.inspect
  sleep 1
  end until @one_client.list( "storage" ).length == storage_num
  
  latest_id = @one_client.list( "storage" ).last.split("/").last.to_i
end

def get_latest_os_tpl_id
  prep_conn( "one" )
  #latest_id = @one_client.list( "/mixin/os_tpl" ).last.split("/").last.to_i
  #puts @one_client.list( "/mixin/os_tpl/" ).inspect
  #puts @one_client.get_os_templates().inspect
  #puts @one_client.get( "/mixin/os_tpl/5" ).inspect
  #puts @one_client.get_os_tpl_mixins_ary( ).inspect
  os_tpls_num = 0
  begin
  puts @one_client.get_os_tpl_mixins_ary( ).inspect
  os_tpls_num = @one_client.get_os_tpl_mixins_ary( ).length
  puts "os_tpls_num:" + os_tpls_num.inspect
  sleep 2
  end until @one_client.get_os_tpl_mixins_ary( ).length == os_tpls_num
  
  #puts @one_client.get_mixin_type_identifiers( ).inspect
  #puts @one_client.list_mixins( "http://schemas.ogf.org/occi/infrastructure/os_tpl" ).inspect
  latest_id = @one_client.get_os_tpl_mixins_ary( ).last.split("_").last.to_i
end

#=begin
def clone_images_os_tpls
  
  source_img = "/storage/125"
  source_os_tpl = "/mixin/os_tpl/5"
  
  #s_new_id = get_latest_storage_id + 1
  #os_new_id = get_latest_os_tpl_id + 1
  #s_new_id = get_latest_storage_id() + 1
  
  prep_conn( "one" )
  for idx in 0..(@@vm_num - 1) do
    puts "idx:" + idx.inspect
    #s_id = s_new_id + idx
    #clone image /storage/9:ubuntu-occi-hd-4G-p
    s_backupaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/storage/action#', term='backup', title='backup storage'
    s_backupactioninstance = Occi::Core::ActionInstance.new s_backupaction, nil
    puts source_img + " state:" + @one_client.get( source_img ).resources.first.attributes.occi.storage.state
    #sleep 1
    @one_client.trigger( source_img, s_backupactioninstance )
    #puts "clone + 1, " + source_img + " state:" + @one_client.get( source_img ).resources.first.attributes.occi.storage.state
    
    os_backupaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/os_tpl/action#', term='clone', title='clone os_tpl'
    os_backupactioninstance = Occi::Core::ActionInstance.new os_backupaction, nil
    #puts source_os_tpl + " state:" + @one_client.get( source_os_tpl ).resources.first.attributes.occi.storage.state
    @one_client.trigger( source_os_tpl, os_backupactioninstance )
    sleep 1
    
  end
  
  puts "all images and os_tpls cloned."
  
end
  

#=begin  
def update_inst_os_tpls
  
  #@one_client.trigger( "/mixin/os_tpl/#{}", os_backupactioninstance )
  
  s_new_id = get_latest_storage_id() - @@vm_num + 1
  sleep 10
  os_new_id = get_latest_os_tpl_id() - @@vm_num + 1
  
  #s_state = "online"
  puts "s_new_id:" + s_new_id.inspect
  puts "os_new_id:" + os_new_id.inspect
  
  
  #s_states = [ "offline", "offline", "offline" ]
  s_states = Array.new( @@vm_num, "offline" )
  #os_states = [ "draft", "draft", "draft" ]
  os_states = Array.new( @@vm_num, "draft" )
  os_states_f = Array.new( @@vm_num, "instantiated" )
  #s_states = []
  
  
  os_updateaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/os_tpl/action#', term='update', title='update os_tpl'
  
  os_instaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/os_tpl/action#', term='instantiate', title='instantiate os_tpl'
  os_instactioninstance = Occi::Core::ActionInstance.new os_instaction, nil
  

  prep_conn( "one" )
  
  begin
    for idx in 0..(@@vm_num - 1) do
#=begin      
      puts "idx:" + idx.inspect
      
      s_id = s_new_id + idx
      os_id = os_new_id + idx
        
        if "draft" == os_states[idx] then
          
          #update os_tpl
=begin          
          os_updateactioninstance = Occi::Core::ActionInstance.new os_updateaction, "DISK = [ IMAGE_ID = #{s_id} ]"
          rc = @one_client.trigger( "/mixin/os_tpl/#{os_id}", os_updateactioninstance )
          if rc then os_states[idx] = "updated" end
=end

          hash = { :occi => { :infrastructure => { :os_tpl => { :image_id => "#{s_id}" } } } }
          #os_attrs = Occi::Core::Attributes.new hash
          #puts os_attrs.convert().inspect
          #puts os_attrs.kind_of?(Occi::Core::Attributes).inspect
          os_updateactioninstance = Occi::Core::ActionInstance.new os_updateaction, hash
          puts os_updateactioninstance.inspect
          rc = @one_client.trigger( "/mixin/os_tpl/#{os_id}", os_updateactioninstance )
          if rc then os_states[idx] = "updated" end
            
        end
          
        if "updated" == os_states[idx] then
          #updated
          s_states[idx] = @one_client.get("/storage/#{s_id}").resources.first.attributes.occi.storage.state
          if "online" == s_states[idx] then
            #go to instantiate
            rc = @one_client.trigger( "/mixin/os_tpl/#{os_id}", os_instactioninstance )
            if rc then os_states[idx] = "instantiated" end
          end
            
          #puts "result of os_tpl instantiate:" + rc.inspect
          
        end
#=end
    end
    # ?
    #end until [ "instantiated", "instantiated", "instantiated" ] == os_states
  end until os_states_f == os_states
  
  puts "all os updated and instantiated."
    
end
#=end

def check_computes
  
  #num = 23
  c_states = Array.new( @@vm_num, "inactive" )
  c_states_f = Array.new( @@vm_num, "active" )
  
  puts "c_states:" + c_states.inspect + ", c_states_f:" + c_states_f.inspect
  
  c_new_id = get_latest_compute_id() - @@vm_num + 1
  
#=begin
  begin
    
    for idx in 0..(@@vm_num - 1) do
      puts idx.inspect
      c_id = c_new_id + idx
      
      if "active" != c_states[idx] then
        c_states[idx] = @one_client.get("/compute/#{c_id}").resources.first.attributes.occi.compute.state
        #c_states[idx] = "active"
        puts "/compute/" + c_id.inspect + " state: " + c_states[idx]
        
      end
    end
  
    puts "c_states:" + c_states.inspect + ", c_states_f:" + c_states_f.inspect
  end until c_states_f == c_states
#=end
  
  puts "all vm running."
  
end


def update_os_tpl
  #prep_conn( "one" )
  os_updateaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/os_tpl/action#', term='update', title='update os_tpl'
  #os_attrs = Occi::Core::Attributes.new
  #os_attrs["DISK"] = "[ IMAGE_ID = 34 ]"
  #os_attrs["DISK"] = "{ \"IMAGE_ID\": \"34\" }"
  hash = { :occi => { :infrastructure => { :os_tpl => { :image_id => "34" } } } }
  #os_attrs = Occi::Core::Attributes.new hash
  #puts os_attrs.convert().inspect
  #puts os_attrs.kind_of?(Occi::Core::Attributes).inspect
  os_updateactioninstance = Occi::Core::ActionInstance.new os_updateaction, hash
  puts os_updateactioninstance.inspect
  rc = @one_client.trigger( "/mixin/os_tpl/25", os_updateactioninstance )
  #puts @one_client.get( "/mixin/os_tpl/2" ).inspect
end

def describe_os_tpl
  #puts @one_client.get_mixin( "lab-occi-one-vm-template-p23", "/mixin/os_tpl" ).inspect
  puts @one_client.get_os_templates().inspect
end

def test_array
  tt = [ "offline", "offline", "offline" ]
  ttt = [ "offline", "offline", "offline" ]
  puts ( [ "offline", "offline", "offline" ] == tt ).inspect
end

def reset
  prep_conn( "one" )
  c_new_id = get_latest_compute_id()
  s_new_id = get_latest_storage_id()
  os_new_id = get_latest_os_tpl_id()
  
  for idx in 0..(@@vm_num - 1) do
    c_id = c_new_id - idx
    s_id = s_new_id - idx
    os_id = os_new_id - idx
    rc = @one_client.delete( "/compute/#{c_id}" )
    puts "delete /compute/" + c_id.inspect + ": " + rc.inspect
    rc = @one_client.delete( "/storage/#{s_id}" )
    sleep 1
    puts "delete /storage/" + s_id.inspect + ": " + rc.inspect
    #rc = @one_client.delete( "/mixin/os_tpl/#{os_id}" )
    #puts "delete /mixin/os_tpl/" + os_id.inspect + ": " + rc.inspect
  end
  #@one_clinet.delete()  
  puts "all new vm/storage/os_tpl deleted."
end

def create_vms_one
  
  source_img = "/storage/863"
  source_os_tpl = "/mixin/os_tpl/5"
  
  #s_new_id = get_latest_storage_id + 1
  #os_new_id = get_latest_os_tpl_id + 1
  #s_new_id = get_latest_storage_id() + 1
  
  prep_conn( "one" )
  for idx in 0..(@@vm_num - 1) do
    puts "idx:" + idx.inspect
    #s_id = s_new_id + idx
    #clone image /storage/9:ubuntu-occi-hd-4G-p
    s_backupaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/storage/action#', term='backup', title='backup storage'
    s_backupactioninstance = Occi::Core::ActionInstance.new s_backupaction, nil
    #puts source_img + " state:" + @one_client.get( source_img ).resources.first.attributes.occi.storage.state
    #sleep 1
    rc = @one_client.trigger( source_img, s_backupactioninstance )
    puts "clone image + 1, result:" + rc.inspect
    #puts "clone + 1, " + source_img + " state:" + @one_client.get( source_img ).resources.first.attributes.occi.storage.state
    
    #os_backupaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/os_tpl/action#', term='clone', title='clone os_tpl'
    #os_backupactioninstance = Occi::Core::ActionInstance.new os_backupaction, nil
    #puts source_os_tpl + " state:" + @one_client.get( source_os_tpl ).resources.first.attributes.occi.storage.state
    #@one_client.trigger( source_os_tpl, os_backupactioninstance )
  
    os_updateaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/os_tpl/action#', term='update', title='update os_tpl'
    s_id = get_latest_storage_id
    puts "get latest_storage_id:" + s_id.inspect
    hash = { :occi => { :infrastructure => { :os_tpl => { :image_id => "#{s_id}" } } } }
    os_updateactioninstance = Occi::Core::ActionInstance.new os_updateaction, hash
    #puts os_updateactioninstance.inspect
    rc = @one_client.trigger( source_os_tpl, os_updateactioninstance )
    #rc = @one_client.trigger( "/mixin/os_tpl/#{os_id}", os_updateactioninstance )
    puts "update os_tpl, result:" + rc.inspect
    
    while "online" != @one_client.get("/storage/#{s_id}").resources.first.attributes.occi.storage.state do
      sleep 5
    end
  
    os_instaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/os_tpl/action#', term='instantiate', title='instantiate os_tpl'
    os_instactioninstance = Occi::Core::ActionInstance.new os_instaction, nil

    rc = @one_client.trigger( source_os_tpl, os_instactioninstance )
    puts "instantiate os_tpl, result:" + rc.inspect
    
  end
  
  puts "all vm created."
  
end

def check_vms_one
    
  cmpt_data = @one_client.list("compute")
  
  puts "cmpt_data:" + cmpt_data.inspect
  
  cmpt_sub = []
  
  for i in 0..(@@vm_num -1) do
    cmpt_sub[i] = cmpt_data[cmpt_data.length - @@vm_num + i].split("/").last
    #puts @one_client.get("/compute/#{cmpt_sub[i]}").inspect
  end
  
  puts "cmpt_sub:" + cmpt_sub.inspect
  
  c_states = Array.new( @@vm_num, "inactive" )
  c_states_f = Array.new( @@vm_num, "active" )
  
  begin
  
    for idx in 0..(@@vm_num - 1) do
      c_id = cmpt_sub[idx]
      c_states[idx] = @one_client.get("/compute/#{c_id}").resources.first.attributes.occi.compute.state
      #c_states[idx] = cmpt_sub[idx].attributes.occi.compute.state
      puts "state of vm" + idx.inspect + ":" + c_states[idx].inspect
    end
    
    sleep 1
    
  end until c_states_f == c_states
  
  puts "all vm running."
  
end

def build_sim_env_one
  create_vms_one()
  check_vms_one()
end

def build_sim_env
  clone_images_os_tpls()
  update_inst_os_tpls()
  check_computes
end

def set_vm_num(num)
  @@vm_num = num
end


#init_clients()
init_client( "one" )
#set_vm_num( ARGV.first.to_i )
#puts @@vm_num.inspect
#puts ARGV
#show
#test()
#list_ec2()
#list_one()
#test_one()
#get_latest_storage_id
#puts @one_client.get("/storage/9").resources.first.attributes.occi.storage.state.inspect
#clone_images_os_tpls()
#build_sim_env()
#get_latest_os_tpl_id
#get_latest_compute_id
#get_latest_storage_id
#clone_images_os_tpls()
#reset()
#get_latest_os_tpl_id()
#get_latest_compute_id()
#update_os_tpl()
#describe_os_tpl()
#get_latest_os_tpl_id.inspect
#test_array
#build_sim_env_one
test_one()


