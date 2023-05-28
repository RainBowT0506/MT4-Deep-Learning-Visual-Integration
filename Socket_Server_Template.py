# -*- coding: utf8 -*-
import json
import socketserver, sys
from time import ctime

HOST= '127.0.0.1'
PORT = 5555


class MT4Server(socketserver.TCPServer):
    # 允許伺服器重用地址
    allow_reuse_address = True

class ServerHandler(socketserver.StreamRequestHandler):

    # 它接收來自客戶端的訊息，使用UTF-8解碼並進行處理。
    def handle(self):

        print('[%s] Client connected from %s ' % (ctime(), self.request.getpeername()))

        while True:
            msg = self.request.recv(7024).strip()
            if not msg:
                pass
            else:

                process_and_write_response(self,msg)

def process_and_write_response(self, msg):
    _strRaw = msg.strip().decode('utf-8')
    print(_strRaw)

    request = json.loads(_strRaw[0:-1])
    print(request["msg"])

    if int(request["Back"]):
        test = request["msg"] + "\r\n"
        self.wfile.write(test.encode("ascii"))


if __name__ == '__main__':
    # 設置 TCP 伺服器的 Python 腳本
    server = MT4Server((HOST, PORT), ServerHandler)
    ip, port = server.server_address
    print("Server is starting at:", (ip, port))
    try:
        server.serve_forever()


    except KeyboardInterrupt:
        import time

        timestr = time.strftime("%Y%m%d-%H-%M")

        sys.exit(0)