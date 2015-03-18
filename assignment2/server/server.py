import sys
import socket
import string
import time
import datetime
import re
from threading import Thread
class clientHandler(Thread):
    def __init__(self, socket, addr):
        Thread.__init__(self, name = "ClientHndlr")
        self._sock = socket
        self._addr = addr
        
    def run(self):
        data = self._sock.recv(1024)
        print data
        sdata = data.split(' ')
        if sdata[0].find('REGISTER') != -1:
            #check users list if already registered
            outstr = "ACK "+sdata[1]+" "+self._addr[0]+" "+repr(self._addr[1])
            self._sock.send(outstr)
            #add to registered users list
        '''
        elif sdata[0].find('LOGIN') != -1:
            #check if user is registered
            #log user in record IP/port
            #flag user as online
        elif sdata[0].find('QUIT') != -1:
            #check if user ip matches on file ip
            #log out if true porse error if not
        elif sdata[0].find('UPDATE') != -1:
            #check user's ip, if correct
            #update user's XML profile
            self._sock.makefile(sdata[1]) #makefile([mode[, buffersize]])
            #self._socket.send("SUCCESS"+timestamp)
        elif sdata[0].find('SEARCH') != -1:
            #search public profile information for keyword sdata[1]
            #self._socket.send("RESULTS"+xml.len+xml)'''
        self._sock.close()
        
        
#parse activty log, populate users list, 
#should be started with a port number
print "press ctrl +z to quit"
TCP = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
TCP.bind(('localhost', int(sys.argv[1])))
TCP.listen(5)

while True:
    sock, addr = TCP.accept()
    print "Connected to", addr
    Client = clientHandler(sock, addr)
    Client.start()
