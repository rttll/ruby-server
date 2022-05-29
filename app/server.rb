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
  
  status = 200
  content_type = 'text/html'
  response_message = '' 

  if request.get? && request.path == '/'  
    store.transaction do
      @birthdays = store[:birthdays]
    end
    
    file = routes[request.path]
    response_message << template(file)

  elsif request.post? && request.path == '/birthdays'
    status = 303
    new_birthday = request.params
    store.transaction do
      store[:birthdays] << new_birthday.transform_keys(&:to_sym)
    end

  else
    content_type = 'text/plain'
    response_message = "✅ Received a #{request.request_method} request to #{request.path}"
  end

  headers = { 
    'Content-Type' => "#{content_type}; charset=#{response_message.encoding.name}", 
    "Location" => "/" 
  }
  body = [response_message]
  [status, headers, body]
}

Rack::Handler::Puma.run(app, :Port => 1337, :Verbose => true) 