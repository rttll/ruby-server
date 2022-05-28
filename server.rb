# mirth.rb
# HTTP Requests:
# Break down HTTP request from the client 
# and displays it 

require 'socket'
require 'erb'

server = TCPServer.new(1337)

loop do
  client = server.accept

  request_line = client.readline

  method_token, target, version_number = request_line.split 
  response_status_code="200 OK"
  content_type ="text/html"
  response_message = ""
  
  puts "request for #{target}"
  
  case [method_token, target]
  when ['GET', '/']
    @foo = 'bar'
    file = File.read('index.html.erb')
    template = ERB.new file
    response_message << template.result(binding)
  when ['GET', '/birthdays']
    response_message << "/birthdays"
  when ['POST', '/birthdays']
  else
    content_type ="text/plain"
    response_message = "✅ Received a #{method_token} request to #{target} with #{version_number}"
  end

  http_response = <<~MSG
    #{version_number} #{response_status_code}
    Content-Type: #{content_type}; charset=#{response_message.encoding.name}
    Location: /birthdays

    #{response_message}
  MSG

  client.puts http_response
  client.close

end