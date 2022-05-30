require 'rack'
require 'rack/handler/puma'
require 'erb'
require 'yaml/store'

app = -> environment {

  Dir.mkdir('db') unless Dir.exist? 'db'
  store = YAML::Store.new("db/db.yml")
  store.transaction do
    store[:birthdays] = [] if store[:birthdays].nil?
  end
  
  routes = {
    '/' => 'index'
  }
  
  @birthdays = []
  
  def template(file)
    file = File.read("#{Dir.pwd}/app/views/#{file}.html.erb")
    erb = ERB.new file
    erb.result(binding)  
  end

  request = Rack::Request.new(environment)
  response = Rack::Response.new
  
  response.content_type = "text/html; charset=UTF-8"

  if request.get? && request.path == '/'  
    store.transaction do
      @birthdays = store[:birthdays]
    end
    
    file = routes[request.path]
    response.write template(file)

  elsif request.post? && request.path == '/birthdays'
    new_birthday = request.params.transform_keys(&:to_sym)
    store.transaction do
      store[:birthdays] << new_birthday.transform_keys(&:to_sym)
    end
    response.redirect('/', 303)
  else
    response.content_type = "text/plain; charset=UTF-8"
    response.write "✅ Received a #{request.request_method} request to #{request.path}"
  end

  response.finish
}

Rack::Handler::Puma.run(app, :Port => 1337, :Verbose => true) 