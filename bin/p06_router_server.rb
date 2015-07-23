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
class Cat < SQLObject
  self.finalize!
  belongs_to :human, foreign_key: :owner_id
end

class Human < SQLObject
  self.table_name = 'humans'
  self.finalize!
  has_many :cats, foreign_key: :owner_id
end

class StatusesController < ControllerBase
  def index
    statuses = $statuses.select do |s|
      s[:cat_id] == Integer(params[:cat_id])
    end
    render_content(statuses.to_s, "text/text")
  end
end

class CatsController < ControllerBase
  def index
    @cats = Cat.all
    render :index
  end

  def flash_demo
    flash[:status] = ["Flash is here!"]
    redirect_to '../cats'
  end

  def flash_now_demo
    flash.now[:status] = ["Flash now is here!"]
    render :flash_now_demo
  end

  def new
    render :new
  end

  def create
    @cat = Cat.new(cat_params)
    if @cat.save
      redirect_to "../cats/#{@cat.id}"
    else
      flash.now[:errors] = ["Invalid Cat Info!"]
      render :new
    end
  end

  def show
    @cat = Cat.find(params[:id])
    render :show
  end

  private

  def cat_params
    params[:cat]
  end
end

router = Router.new
router.draw do
  get  Regexp.new("^/cats/flash$"), CatsController, :flash_demo
  get  Regexp.new("^/cats/flash_now$"), CatsController, :flash_now_demo
  get  Regexp.new("^/cats$"), CatsController, :index
  get  Regexp.new("^/cats/new$"), CatsController, :new
  post Regexp.new("^/cats$"), CatsController, :create
  get  Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
