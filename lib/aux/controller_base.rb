class ControllerBase
  attr_reader :req, :res, :params
  # Setup the controller
  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = Params.new(req, route_params)
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Already rendered" if already_built_response?
    res.status = 302
    res.header['location'] = url
    @already_built_response = true
    session[:flash] = flash.store
    session[:authenticity_token] = SecureRandom.urlsafe_base64(16)
    session.store_session(res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Already rendered" if already_built_response?
    res.content_type = content_type
    res.body = content
    @already_built_response = true
    session.store_session(res)
  end

  def render(template_name)
    token = SecureRandom.urlsafe_base64(16)
    session[:authenticity_token] = token
    form_auth_token = token
    session[:flash] = flash.store
    flash.store = flash.store.merge(flash.now)
    content = File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb")
    content_erb = ERB.new(content).result(binding)
    main_template = File.read("views/application.html.erb")
    main_erb = ERB.new(main_template).result(binding)
    render_content(main_erb, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  def invoke_action(name)
    method = req.request_method.to_s.downcase
    if method == "post" || method == "patch"
      raise "Form Authenticity Error!" unless session[:authenticity_token] == params[:authenticity_token]
    end
    send(name)
  end

  # method exposing a `Flash` object
  def flash
    @flash ||= Flash.new(req)
  end

end
