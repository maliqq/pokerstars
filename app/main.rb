require 'models'
require 'helpers'
require 'async'

class Application < Sinatra::Base
  set :root, ROOT
  set :views, File.join(File.dirname(__FILE__), 't')
  set :public, Proc.new { File.join(root, 'static') }
  enable :sessions

  configure :development do
    register Sinatra::Reloader
    also_reload "#{ROOT}/app/*.rb"
  end

  helpers Helpers

  get '/' do
    @files = Dir[ENV['PS_PATH'] + '/*']
    erb :files
  end

  get '/import' do
    @files = Dir[ENV['PS_PATH'] + '/*']
    @files.each do |file|
      File.open(file) { |f|
        @h = PokerStars::HandHistory::Parser.new(f)
        @h.parse { |data|
          puts data.inspect
          Hand.create!(data)
        }
      }
    end
    'ok'

  end
end
