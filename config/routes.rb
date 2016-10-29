ROCCIServer::Application.routes.draw do

  ####################################################
  ## Occi::Core::Mixin (user-defined mixins)
  ####################################################
  get '/mixin/*term/', to: 'mixin#index', as: 'mixin'

  post '/mixin/*term/', to: 'mixin#trigger', constraints: { query_string: /^action=\S+$/ }
  post '/mixin/*term/', to: 'mixin#assign', as: 'assign_mixin'

  put '/mixin/*term/', to: 'mixin#update', as: 'update_mixin'

  delete '/mixin/*term/', to: 'mixin#delete', as: 'unassign_mixin'


  ####################################################
  ## seewt/movies
  ####################################################
  get '/movies/gotp_video-5558819', to: 'seewt#video_display'
  get '/movies/gotp_video-5561907', to: 'seewt#video_display'
  get '/movies/gotp_video-5561863', to: 'seewt#video_display'
  get '/movies/gotp_video-5549041', to: 'seewt#video_display'

  get '/movies/youtube_video-7J0fRj04s8U', to: 'seewt#video_display'
  get '/movies/youtube_video-tjosS9Ce3PM', to: 'seewt#video_display'
  get '/movies/youtube_video-9i-q6O3pRBM', to: 'seewt#video_display'
  get '/movies/youtube_video-vg4YRTx5KwE', to: 'seewt#video_display'
  get '/movies/youtube_video-LQcTMtELEeQ', to: 'seewt#video_display'
  get '/new_simulatoin/youtube_video-cc5JQ8tj0Ew', to: 'seewt#video_display'
  get '/movies/iqiyi_video-3225b6b8f5e8df25', to: 'seewt#video_display'

  get '/videojs/youtube_video-0Jjj48fi-A0', to: 'seewt#videojs_display'
  
  get '/movies/baidupcs_video-test', to: 'seewt#baidupcs_test'


  ####################################################
  ## seewt#dramas
  ####################################################


  ####################################################
  ## seewt
  ####################################################
  get '/contact', to: 'seewt#contact'
  get '/about', to: 'seewt#about'

  get '/dramas', to: 'seewt#dramas'
  get '/movies', to: 'seewt#movies'
  get '/lives', to: 'seewt#lives'

  ####################################################
  ## Default route
  ####################################################
  root 'seewt#welcome'
end
