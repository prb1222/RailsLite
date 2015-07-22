class Flash
  def initialize(req)
    result = req.cookies.select{|cookie| cookie.name == '_rails_lite_app_flash'}
    if result.empty?
      @store = {}
    else
      @store = JSON.parse(result.first.value)
    end
  end

  def [](key)
    @store[key]
  end

  def []=(key, val)
    @store[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_flash(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app_flash', @store.to_json)
  end
end
