require_relative '../lib/aux/auxiliary'
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

$cats = [
  { id: 1, name: "Curie" },
  { id: 2, name: "Markov" }
]

$statuses = [
  { id: 1, cat_id: 1, text: "Curie loves string!" },
  { id: 2, cat_id: 2, text: "Markov is mighty!" },
  { id: 3, cat_id: 1, text: "Curie is cool!" }
]

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
    @cats = $cats.to_s
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
    @cat = {id: 3, name: "Tibbles", owner: "Annie"}
    render :show
  end

  private

  def cat_params
    params.require(:cat).permit(:name, :owner)
  end
end

router = Router.new
router.draw do
  get  Regexp.new("^/cats/flash$"), CatsController, :flash_demo
  get  Regexp.new("^/cats/flash_now$"), CatsController, :flash_now_demo
  get  Regexp.new("^/cats$"), CatsController, :index
  get  Regexp.new("^/cats/new$"), CatsController, :new
  post Regexp.new("^/cats$"), CatsController, :create
  get  Regexp.new("^/cats/(?<cat_id>\\d+)/statuses$"), StatusesController, :index
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
