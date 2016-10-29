# Controller class 

#first version

require 'rubygems'
require "nokogiri"
require "open-uri"
require "open3"

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
EC2_USERNAME = ''
EC2_PASSWORD = ''
#default deployment: one/ec2 ratio, e.g: 0.5, 0.75, 1.0, 2.0, 5.0


OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE


class SeewtController < ApplicationController

  @@one_ec2_ratio = 1
  @@vm_num_one = 0
  @@vm_num_ec2 = 0
  @@data_updated = 0
  
  # DEFAULT
  # GET /
  def welcome
    #puts "daniel: issc#welcome"  
    #File.open("/opt/ISSC/daniel.log", "a+") { |f| f.puts t.strftime("%H:%M:%S:%L") + " [daniel] issc_controller.rb, welcome().request: " }  
  end

  def dramas

  end

  def movies

  end

  def lives

  end

  def videojs_display
    video_display
  end

  def baidupcs_test
    video_display
  end

  def video_display
    #pp "daniel: request.original_url: " + request.original_url
    #pp "daniel: request: " + request.fullpath
    parts = File.basename(request.fullpath).partition("_")
    web = parts[0]
    vid = parts[2].partition("video-")[2]
    pp "vid: "+ vid
    @vurl = ""
    #video type: type="application/x-mpegURL", type="video/mp4"
    @vtype = "video/mp4"
    
    case web
    when "gotp"
      #pp "gotp_vid: " + vid
      @vurl = gotp_vid_to_url vid
      @vtype = "video/mp4"
    when "youtube"
      #pp "youtube"
      @vurl = youtube_vid_to_url vid
      @vtype = "video/mp4"
    when "iqiyi"
      @vurl = iqiyi_vid_to_url vid
      # @vurl = "http://f24hls-i.akamaihd.net/hls/live/221193/F24_EN_LO_HLS/master_1200.m3u8"
      # @vurl = "http://k.youku.com/player/getFlvPath/sid/3472005488780128fe779_00/st/flv/fileid/0300010F0E57BA7A0186132BEEFCF919991AFE-0280-727C-DD75-7F597FD5DECD?ypp=0&myp=0&K=5b8d985c3f8085ad2412b7af&ctype=12&token=1704&ev=1&ep=cSaTGEmNU8oI7STXiD8bb3q3c3AGXP4J9h%2BFgNIUAM4hT5rOnk%2FRxpW2T%2FxAZIxsBFFwGer4otnmGzZhYfBBoWgQ2EyvSvqUivfm5aolwZkHEG0zBrikwFSfRDD1&hd=1&oip=1857209301"
      @vtype = "application/x-mpegURL"
      #@vtype = "application/vnd.apple.mpegurl"
    when "baidupcs"
      @vurl = baidupcs_vid_to_url vid
      @vtype = "video/mp4"
    when "test"
      @vurl = ""
      @vtype = ""
      
    end

    # puts "daniel: request.base_url: " + request.base_url + ", request.original_fullpath: " + request.original_fullpath"

    pp "vurl: " + @vurl

    @vurl

  end

  def baidupcs_vid_to_url(vid)
    turl = ""
    url = "https://pcs.baidu.com/rest/2.0/pcs/stream?method=download&access_token=23.3c473ff6aea5aafe94bfc16a2ee1cd8b.2592000.1480200057.2644256190-2293434&path=%2Fapps%2FSyncY%2Fseewhat%2Fmovies%2Fxiaoshenkedejiushu.rmvb"
    # url = "https://pcs.baidu.com/rest/2.0/pcs/stream?method=download&access_token=23.3c473ff6aea5aafe94bfc16a2ee1cd8b.2592000.1480200057.2644256190-2293434&path=%2Fapps%2FSyncY%2Fseewhat%2Fmovies%2Ffushanxing.mp4"
    # url = "https://pcs.baidu.com/rest/2.0/pcs/file?method=download&access_token=23.3c473ff6aea5aafe94bfc16a2ee1cd8b.2592000.1480200057.2644256190-2293434&path=%2Fapps%2FSyncY%2Fseewhat%2Fmovies%2Ffushanxing.mp4"
  end

  def iqiyi_vid_to_url(vid)
    turl = iqiyi_vid_to_turl vid
    #pp "turl: " + turl
    url = iqiyi_parse_turl turl
  end

  def iqiyi_vid_to_turl(vid)
    case vid
    when "3225b6b8f5e8df25"
      turl = "http://www.iqiyi.com/dianying/20121213/3225b6b8f5e8df25.html"
    end

    turl
  end

  def iqiyi_parse_turl(turl)
    geo_options = "--geo-verification-proxy http://110.178.195.213:8888"
    url = generic_parse_turl turl, geo_options
    url
  end

  def youtube_vid_to_url(vid)
    turl = youtube_vid_to_turl vid
    #pp "turl: " + turl
    url = youtube_parse_turl turl
  end

  def youtube_vid_to_turl(vid)
    turl = "https://www.youtube.com/watch?v=" + vid
    turl
  end

  def youtube_parse_turl(turl)
    url = generic_parse_turl turl
    url
  end

  def generic_parse_turl(turl, options="")
    stdin, stdout, stderr = Open3.popen3("/usr/local/bin/youtube-dl -g #{turl} #{options}")
    url = stdout.readlines[0].chomp
    #pp url
    url
  end

  def video_display_gotp
    #pp "daniel: request.original_url: " + request.original_url
    #pp "daniel: request: " + request.fullpath
    parts = File.basename(request.fullpath).partition("_")
    web = parts[0]
    vid = parts[2]
    @vurl = ""
    
    case web
    when "gotp"
      #pp "gotp_vid: " + vid
      @vurl = gotp_vid_to_url vid
    when "youtube"
      #pp "youtube"
      
    end

    # puts "daniel: request.base_url: " + request.base_url + ", request.original_fullpath: " + request.original_fullpath"

    pp @vurl

    @vurl

  end

  def gotp_vid_to_url(vid)
    turl = gotp_vid_to_turl vid
    url = gotp_parse_turl turl
  end

  def gotp_vid_to_turl(vid)
    case vid
    when "video-5558819"
      turl = "http://www.gotporn.com/fucked-in-traffic-slutty-bitch-meggie-marika-getting-rammed-on-the-backseat-of-the-car/video-5558819"
    when "video-5561907"
      turl = "http://www.gotporn.com/fucked-in-traffic-skinny-bitch-katrina-grand-getting-her-hands-on-hard-cock/video-5561907"
    when "video-5561863"
      turl = "http://www.gotporn.com/fucked-in-traffic-blonde-cunt-claudia-macc-giving-a-bj-to-her-chauffer/video-5561863"
    when "video-5549041"
      turl = "http://www.gotporn.com/petite-blonde-chick-gets-pulled-over-and-fucked-on-cop-car/video-5549041"
    end

    turl
  end

  def gotp_parse_turl(turl)
    # user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36"
    # html = open(turl, "User-Agent" => user_agent)   
    # doc = Nokogiri::HTML(html)
    # #pp doc.inner_html.class
    # File.open("/opt/ISSC/gotp.html","w") { |f|
    #   doc.inner_html.each_line { |line|
    #     f.puts line
    #   }
    # }
    # url = doc.css("#html5-player")[0].attribute("src").value


    stdin, stdout, stderr = Open3.popen3("/usr/local/bin/youtube-dl -g #{turl}")
    url = stdout.readlines
    pp url
    url
  end
  
end
