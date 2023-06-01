# -*- coding: utf8 -*-
import json
import socketserver, sys
from time import ctime
import numpy
import pandas as pd
import joblib
from pandas import json_normalize


HOST= '127.0.0.1'
PORT = 5555
clf3 = joblib.load('cf.pkl')


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


                #將送來的JSON轉成Array
                # print(request)
                #需注意輸入特徵的順序，必需與匯出資料、訓練模型時一致
                test_Data = pd.DataFrame.from_dict(request, orient='index')

                #Reshape，將裡面的屬性改成當時訓練模型的矩陣一樣的屬性
                cu = test_Data.values.reshape(1, 8)
                # print(cu)

                #計算結果
                predict = clf3.predict(cu)
                print(predict)
                # request = json.loads(_strRaw[0:-1])
                #print(request["msg"])

                # if int(request["Back"]):

                test = str(predict[0]) + "\r\n"
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