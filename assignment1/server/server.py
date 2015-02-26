import sys
import socket
import string
import time
import datetime

class userClass:
    #tuple username first name last name
    def __init__(self, userName):
        self._userName = userName
        self._online = False
        self._friends = []
        self._lastUpdate = time.time()
        self._lUHR = datetime.datetime.fromtimestamp(self._lastUpdate).strftime('%Y-%m-%d %H:%M:%S')

    def reg(self, fname, lname):
        self._Names = [fname, lname]
    
    #list of friends
    def addFriend(self, newFriend):
        self._friends.append(newFriend)

    #bool online status
    def isOnline(self):
        return(self._online)

    #tuple of current address
    def logOn(self, addr):
        self._online = True
        self._IP = addr[0]
        self._port = addr[1]
    
    def logOff(self):
        self._online = False
        self._IP = NULL
        self._port = NULL    
    #xml profile page
     
#parse activty log, populate users list, 
#should be started with a port number

while 1:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(('localhost', int(sys.argv[1])))
    s.listen(5)
    
    while True:
        sock, addr = s.accept()
        print "Connected to", addr
        data = sock.recv(1024)
        input_string = string.split(data, ' ', 1)
        for words in input_string:
            print words
        #check for what action to take
        #if register add to registry
            #send ACK
        #if login record address, and port and update user table
        #if quit check ip matches user and drop from user table
        #if requesting friendship with user2 
            #send wall message to user2 asking for friendshop
        #if reject, do not relay message
        #if chat user-id mes send message to user-id
            #if on relay, if off respond offline
            #once delievered send delievered message
        #if post wall post to friends and fof or pub can see
        #if search, use regx to find results in profiles
            #return results msg w/ file len, in xml
        #if entries get all wall posts since time in reverse order
            #return wall message w/ file len, in xml
    
