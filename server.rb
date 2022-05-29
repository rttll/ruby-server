# mirth.rb
# HTTP Requests:
# Break down HTTP request from the client 
# and displays it 

require 'socket'
require 'erb'

server = TCPServer.new(1337)

routes = {
  '/' => 'index'
}

def template(file)
  file = File.read("#{file}.html.erb")
  erb = ERB.new file
  erb.result(binding)  
end

@birthdays = []

loop do
  client = server.accept

  request_line = client.readline

  method_token, target, version_number = request_line.split 
  response_status_code="200 OK"
  content_type ="text/html"
  response_message = ""

  puts "incoming: #{method_token} #{target}"

  case [method_token, target]
  when ['GET', '/']
    file = routes[target]
    response_message << template(file)
  when ['POST', '/birthdays']
    response_status_code = "303 See Other"
    
    all_headers = {}
    while true
      line = client.readline 
      break if line == "\r\n"
      header_name, value = line.split(": ")
      all_headers[header_name] = value
    end
    body = client.read(all_headers['Content-Length'].to_i)
    require 'uri'
    new_birthday = URI.decode_www_form(body).to_h
    @birthdays << new_birthday.transform_keys(&:to_sym)

  else
    content_type ="text/plain"
    response_message = "✅ Received a #{method_token} request to #{target} with #{version_number}"
  end

  http_response = <<~MSG
    #{version_number} #{response_status_code}
    Content-Type: #{content_type}; charset=#{response_message.encoding.name}
    Location: /

    #{response_message}
  MSG

  client.puts http_response
  client.close

end