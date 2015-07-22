require 'json'
require 'webrick'
require 'byebug'
module Phase4
  class Session
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      result = req.cookies.select{|cookie| cookie.name == '_rails_lite_app'}
      if result.empty?
        @cookie = {}
      else
        @cookie = JSON.parse(result.first.value)
      end
    end

    def [](key)
      @cookie[key]
    end

    def []=(key, val)
      @cookie[key] = val
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_session(res)
      res.cookies << WEBrick::Cookie.new('_rails_lite_app', @cookie.to_json)
    end
  end
end
