# -*- coding: utf8 -*-
import json
import socketserver, sys
from time import ctime

HOST= '127.0.0.1'
PORT = 5555


class MT4Server(socketserver.TCPServer):

    allow_reuse_address = True

class ServerHandler(socketserver.StreamRequestHandler):
    def handle(self):

        print('[%s] Client connected from %s ' % (ctime(), self.request.getpeername()))

        while True:
            msg = self.request.recv(7024).strip()
            if not msg:
                pass
            else:

                _strRaw = msg.strip().decode('utf-8')
                print(_strRaw)


                request = json.loads(_strRaw[0:-1])
                print(request["msg"])

                if int(request["Back"]):

                    test = request["msg"] + "\r\n"
                    self.wfile.write(test.encode("ascii"))


if __name__ == '__main__':
    server = MT4Server((HOST, PORT), ServerHandler)
    ip, port = server.server_address
    print("Server is starting at:", (ip, port))
    try:
        server.serve_forever()


    except KeyboardInterrupt:
        import time

        timestr = time.strftime("%Y%m%d-%H-%M")

        sys.exit(0)