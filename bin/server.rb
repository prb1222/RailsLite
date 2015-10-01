require_relative '../lib/aux/auxiliary'
require_relative '../lib/activerecord/lib/sql_object'
require 'webrick'
require 'byebug'
require 'json'
require 'active_support'
require 'active_support/core_ext'
require 'SecureRandom'
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html

# Creates a Corgi model class
class Corgi < SQLObject
  self.finalize!
  belongs_to :human, foreign_key: :owner_id
end

#Creates a Human model class and sets custom table name for db
class Human < SQLObject
  self.table_name = 'humans'
  self.finalize!
  has_many :corgis, foreign_key: :owner_id
end


class CorgisController < ControllerBase
  def root
    render :root
  end

  def index
    @corgis = Corgi.all
    render :index
  end

  def flash_demo
    flash[:status] = ["Flash is here!"]
    redirect_to '../corgis'
  end

  def flash_now_demo
    flash.now[:status] = ["Flash now is here!"]
    render :flash_now_demo
  end

  def new
    render :new
  end

  def create
    @corgi = Corgi.new(corgi_params)
    if @corgi.save
      redirect_to "../corgis/#{@corgi.id}"
    else
      flash.now[:errors] = ["Invalid Corgi Info!"]
      render :new
    end
  end

  def show
    @corgi = Corgi.find(params[:id])
    render :show
  end

  private

  def corgi_params
    params[:corgi]
  end
end

router = Router.new
router.draw do
  get  Regexp.new("^/$"), CorgisController, :index
  get  Regexp.new("^$"), CorgisController, :index
  get  Regexp.new("^/corgis/flash$"), CorgisController, :flash_demo
  get  Regexp.new("^/corgis/flash_now$"), CorgisController, :flash_now_demo
  get  Regexp.new("^/corgis$"), CorgisController, :index
  get  Regexp.new("^/corgis/new$"), CorgisController, :new
  post Regexp.new("^/corgis$"), CorgisController, :create
  get  Regexp.new("^/corgis/(?<id>\\d+)$"), CorgisController, :show
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
