require 'rack'
require 'rack/handler/puma'
require 'erb'
require 'sqlite3'

app = -> environment {

  database = SQLite3::Database.new("db.sqlite3", results_as_hash: true)
  
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
    @birthdays = database.execute("SELECT * FROM birthdays")
    
    file = routes[request.path]
    response.write template(file)

  elsif request.post? && request.path == '/birthdays'
    new_birthday = request.params.transform_keys(&:to_sym)
    query = "INSERT INTO birthdays (name, date) VALUES (?, ?)"
    database.execute(query, [new_birthday[:name], new_birthday[:date]])
    response.redirect('/', 303)
  else
    response.content_type = "text/plain; charset=UTF-8"
    response.write "✅ Received a #{request.request_method} request to #{request.path}"
  end

  response.finish
}

Rack::Handler::Puma.run(app, :Port => 1337, :Verbose => true) 