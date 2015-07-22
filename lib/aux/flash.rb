class Flash
  attr_accessor :store
  def initialize(req)
    result = req.cookies.select{|cookie| cookie.name == '_rails_lite_app'}.first
    unless result
      @flash_now = {}
      @store = {}
      return
    end

    session_hash = JSON.parse(result.value)
    if session_hash.empty?
      @flash_now = {}
    else
      @flash_now = session_hash['flash']
    end
    @store = {}
  end

  def [](key)
    @store[key.to_sym] || @store[key.to_s]
  end

  def []=(key, val)
    @store[key] = val
  end

  def now
    @flash_now
  end
end
