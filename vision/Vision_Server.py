# -*- coding: utf8 -*-
import numpy as np
import os
os.environ["CUDA_VISIBLE_DEVICES"]="-1"
import tensorflow as tf
import json
import socketserver, sys, threading
from time import ctime
import cv2
from PIL import Image
import matplotlib.pyplot as plt






graph_def = tf.compat.v1.GraphDef()
labels = []
#load model
filename = 'model.pb'
labels_filename ='labels.txt'

# Import the TF graph
with tf.io.gfile.GFile(filename, 'rb') as f:
    graph_def.ParseFromString(f.read())
    tf.import_graph_def(graph_def, name='')

# Create a list of labels.
with open(labels_filename, 'rt') as lf:
    for l in lf:
        labels.append(l.strip())


def convert_to_opencv(image):
    # RGB -> BGR conversion is performed as well.
    image = image.convert('RGB')
    r,g,b = np.array(image).T
    opencv_image = np.array([b,g,r]).transpose()
    return opencv_image

def crop_center(img,cropx,cropy):
    h, w = img.shape[:2]
    startx = w//2-(cropx//2)
    starty = h//2-(cropy//2)
    return img[starty:starty+cropy, startx:startx+cropx]

def resize_down_to_1600_max_dim(image):
    h, w = image.shape[:2]
    if (h < 1600 and w < 1600):
        return image

    new_size = (1600 * w // h, 1600) if (h > w) else (1600, 1600 * h // w)
    return cv2.resize(image, new_size, interpolation = cv2.INTER_LINEAR)

def resize_to_256_square(image):
    h, w = image.shape[:2]
    return cv2.resize(image, (256, 256), interpolation = cv2.INTER_LINEAR)

def update_orientation(image):
    exif_orientation_tag = 0x0112
    if hasattr(image, '_getexif'):
        exif = image._getexif()
        if (exif != None and exif_orientation_tag in exif):
            orientation = exif.get(exif_orientation_tag, 1)
            # orientation is 1 based, shift to zero based and flip/transpose based on 0-based values
            orientation -= 1
            if orientation >= 4:
                image = image.transpose(Image.TRANSPOSE)
            if orientation == 2 or orientation == 3 or orientation == 6 or orientation == 7:
                image = image.transpose(Image.FLIP_TOP_BOTTOM)
            if orientation == 1 or orientation == 2 or orientation == 5 or orientation == 6:
                image = image.transpose(Image.FLIP_LEFT_RIGHT)
    return image


HOST= '127.0.0.1'
PORT = 5555



def to_bool(value):
    valid = {'true': True, 't': True, '1': True,
             'false': False, 'f': False, '0': False,
             }

    if isinstance(value, bool):
        return value

    if not isinstance(value, np.basestring):
        raise ValueError('invalid literal for boolean. Not a string.')

    lower_value = value.lower()
    if lower_value in valid:
        return valid[lower_value]
    else:
        raise ValueError('invalid literal for boolean: "%s"' % value)







class MyServer(socketserver.TCPServer):
    # daemon_threads = True
    allow_reuse_address = True

class MyHandler(socketserver.StreamRequestHandler):
    def handle(self):

        print('[%s] Client connected from %s and  is handling with him.' % (ctime(), self.request.getpeername()))
        self.request.sendall(b'ok')
        while True:
            msg = self.request.recv(7024).strip()
            if not msg:
                pass
            else:

                _strRaw = msg.strip().decode('utf-8')


                request = json.loads(_strRaw[0:-1])



                if int(request["Back"]):
                    # Load from a file
                    #back testing
                    #C:\Users\.....\tester\files
                    imageFile = "C:/Users/RainBowT/AppData/Roaming/MetaQuotes/Terminal/BCF7551C28C1FB834F312E284FD97AE9/tester/files/"+request["Symbol"]+".png"

                    image = Image.open(imageFile)

                    # Update orientation based on EXIF tags, if the file has orientation info.
                    # width, height = image.size   # Get dimensions
                    top = 4 #放入要裁切的Top初始值
                    left = 1322 #放入要裁切的Left初始值
                    width  = 206 #放入要裁切的最右邊的值
                    height  =421 #放入要裁切的右下的值
                    image = image.crop((left, top, left+width, top+height))

                    #確認裁切後的畫面是不是否符合我們預期的
                    # plt.imshow(image)
                    # plt.show()

                    # Update orientation based on EXIF tags, if the file has orientation info.
                    image = update_orientation(image)

                    # Convert to OpenCV format
                    image = convert_to_opencv(image)
                    # If the image has either w or h greater than 1600 we resize it down respecting
                    # aspect ratio such that the largest dimension is 1600
                    image = resize_down_to_1600_max_dim(image)
                    # We next get the largest center square
                    h, w = image.shape[:2]
                    min_dim = min(w, h)
                    max_square_image = crop_center(image, min_dim, min_dim)
                    # Resize that square down to 256x256
                    augmented_image = resize_to_256_square(max_square_image)
                    # The compact models have a network size of 227x227, the model requires this size.
                    network_input_size = 227

                    # Get the input size of the model
                    with tf.Session() as sess:
                        input_tensor_shape = sess.graph.get_tensor_by_name('Placeholder:0').shape.as_list()
                    network_input_size = input_tensor_shape[1]

                    # Crop the center for the specified network_input_Size
                    augmented_image = crop_center(augmented_image, network_input_size, network_input_size)

                    # These names are part of the model and cannot be changed.
                    output_layer = 'loss:0'
                    input_node = 'Placeholder:0'

                    with tf.Session() as sess:
                        try:
                            prob_tensor = sess.graph.get_tensor_by_name(output_layer)
                            predictions, = sess.run(prob_tensor, {input_node: [augmented_image]})
                        except KeyError:
                            print("Couldn't find classification output layer: " + output_layer + ".")
                            print("Verify this a model exported from an Object Detection project.")
                            exit(-1)

                    highest_probability_index = np.argmax(predictions)
                    print('Classified as: ' + labels[highest_probability_index])


                    # Or you can print out all of the results mapping labels to probabilities.
                    label_index = 0
                    for p in predictions:
                        truncated_probablity = np.float64(round(p, 8))
                        print(labels[label_index], truncated_probablity)
                        label_index += 1

                    pvalue = predictions[highest_probability_index]
                    print("辨視度",pvalue)

                    if pvalue > 0.7:
                        test = str(highest_probability_index) + "\r\n"
                        print(test)
                    else:
                        test = "3" + "\r\n"






                    self.wfile.write(test.encode("ascii"))


if __name__ == '__main__':
    server = MyServer((HOST,PORT), MyHandler)
    ip, port = server.server_address
    print("Server is starting at:", (ip, port))
    try:
        server.serve_forever()


    except KeyboardInterrupt:
        import time
        timestr = time.strftime("%Y%m%d-%H-%M")

        sys.exit(0)