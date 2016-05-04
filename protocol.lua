require "luasocket"

host = socket.dns.gethostname()

io.write(host)