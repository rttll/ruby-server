# mirth.rb
# HTTP Requests:
# Break down HTTP request from the client 
# and displays it 

require 'socket'

server = TCPServer.new(1337)

loop do
  client = server.accept

  request_line = client.readline

  puts "The HTTP request line looks like this:"
  puts request_line

  method_token, target, version_number = request_line.split 
  response_status_code="200 OK"
  content_type ="text/plain"
  response_message = ""
  
  case [method_token, target]
  when ['GET', '/birthdays']
    response_message << "hi"
  when ['POST', '/birthdays']
  else
    response_message = "✅ Received a #{method_token} request to #{target} with #{version_number}"
  end

  http_response = <<~MSG
    #{version_number} #{response_status_code}
    Content-Type: #{content_type}; charset=#{response_message.encoding.name}
    Location: /show/birthdays

    #{response_message}
  MSG
  
  puts http_response

  client.puts http_response
  client.close

end