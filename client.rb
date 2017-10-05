require 'restclient'

puts "Blockchain client"
print("Specify the port: ")
port = gets.chomp

loop do
  begin
    print "#{port}> "
    msg = gets.chomp
    x = RestClient.post "http://localhost:#{port}/chain/add", msg
    puts x
  rescue => e
    puts e.message
  end
end
