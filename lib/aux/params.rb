class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  #
  # You haven't done routing yet; but assume route params will be
  # passed in as a hash to `Params.new` as below:
  def initialize(req, route_params = {})
    @params = parse_www_encoded_form(req.query_string)
    @params.merge!(parse_www_encoded_form(req.body))
    @params.merge!(route_params)
  end

  def [](key)
    @params[key.to_sym] || @params[key.to_s]
  end

  # this will be useful if we want to `puts params` in the server log
  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  # private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    return {} if www_encoded_form.nil?
    array = URI::decode_www_form(www_encoded_form)
    hash = {}
    array.each do |el|
      current = hash
      parsed_array = parse_key(el.first)
      parsed_array[0...-1].each do |key|
        current[key] ||= {}
        current = current[key]
      end
      current[parsed_array.last] = el.last
    end
    hash
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/).map(&:to_sym)
  end
end
