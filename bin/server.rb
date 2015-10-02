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
    byebug
    @corgi = Corgi.new(corgi_params)
    if @corgi.save
      puts "GOT TO HEREGOT TO HEREGOT TO HEREGOT TO HEREGOT TO HEREGOT TO HEREGOT TO HEREGOT TO HEREGOT TO HEREGOT TO HEREGOT TO HEREGOT TO HERE"
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

  def about
    render :about
  end

  private

  def corgi_params
    params[:corgi]
  end
end

class HumansController < ControllerBase
  def new
    render :new
  end

  def create
    @user = Human.new(user_params)
    if @human.save
      redirect_to "../humans/#{@human.id}"
    else
      flash.now[:errors] = ["Invalid User Info!"]
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
    render :show
  end

  def login_page
    render :login_page
  end

  def login
    @user = Human.find(fname: user_params[:fname], lname: user_params[:lname])
    if @user
      session[:session_token] = SecureRandom.urlsafe_base64(16)
      redirect_to "/"
    else
      flash.now[:errors] = ["Invalid User Info!"]
      render :login_page
    end
  end

  def logout
    session[:session_token] = nil
    redirect_to "/"
  end

  private

  def user_params
    params[:user]
  end
end


router = Router.new
router.draw do
  get  Regexp.new("^/$"), CorgisController, :index
  get  Regexp.new("^$"), CorgisController, :index
  get  Regexp.new("^/about$"), CorgisController, :about
  get  Regexp.new("^/corgis/flash$"), CorgisController, :flash_demo
  get  Regexp.new("^/corgis/flash_now$"), CorgisController, :flash_now_demo
  get  Regexp.new("^/corgis$"), CorgisController, :index
  get  Regexp.new("^/corgis/new$"), CorgisController, :new
  post Regexp.new("^/corgis$"), CorgisController, :create
  get  Regexp.new("^/corgis/(?<id>\\d+)$"), CorgisController, :show
  get  Regexp.new("^/humans$"), HumansController, :show
  get  Regexp.new("^/humans/(?<id>\\d+)$"), HumansController, :show
  get  Regexp.new("^/humans/new$"), HumansController, :new
  post Regexp.new("^/humans$"), HumansController, :create
  get  Regexp.new("^/humans/login$"), HumansController, :login_page
  post Regexp.new("^/humans/login$"), HumansController, :login
  delete Regexp.new("^/humans$"), HumansController, :logout
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
