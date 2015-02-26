import sys
import socket
import string
import threading
import time
import datetime
import re

class userClass:
    #tuple username first name last name
    def __init__(self, userName):
        self._userName = userName
        self._online = False
        self._friends = []
        self._lastUpdate = time.time() #used from stackextange example of timestamps
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

class clientHandler:
    def __init__(self, socket, address, userlist):
        self._socket = socket
        self._addr = address
        self._userList = userlist
        
    def REG(Usernames):
        userNames = string.split(Usernames, ' ')
        found = False
        for users in self._userList:
            if not (string.find(users._userName, userNames[0]) == -1):
                found = True
                self._socket.sendall("ACK", userNames[0], self._addr[0], self._addr[1])
                return
        newUser = userClass(userNames[0])
        newUser.reg(userNames[1], userNames[2])
        self._socket.sendall("ACK", userNames[0], self._addr[0], self._addr[1])
        self._userList.append(newUser)
        return
        
    def threadName(self, name):
        self._treadName = name
        
    def run(self):
        while 1:
            data = self._socket.recv(1024)
            if not data: break #if no data return
            #check for what action to take
            else: inputString = string.split(data, ' ', 1)
            if string.find(inputString[0], "REGISTER"):
            #if register add to registry
                #send ACK
                self.REG(inputString[1], 3)
            #elif string.find(inputString[0], "UPDATE"):
            #attach xml doc to profile file
            #elif string.find(inputString[0], "LOGIN"):
            #if login record address, and port and update user table
            #elif string.find(inputString[0], "QUIT"):
            #if quit check ip matches user and drop from user table
            #elif string.find(inputString[0], "FRIEND"):
            #if requesting friendship with user2 
                #send wall message to user2 asking for friendshop
            #elif string.find(inputString[0], "CONFIRM"):
            #append user's friend list in both cases
            #elif string.find(inputString[0], "REJECT"):
            #if reject, do not relay message
            #elif string.find(inputString[0], "CHAT"):
            #if chat user-id mes send message to user-id
                #if on relay, if off respond offline
                #once delievered send delievered message
            #elif string.find(inputString[0], "POST"):
            #if post wall post to friends and fof or pub can see
            #elif string.find(inputString[0], "ENTRIES"):
            #if entries get all wall posts since time in reverse order
                #return wall message w/ file len, in xml
            #elif string.find(inputString[0], "SEARCH"):
            #if search, use regx to find results in profiles
                #return results msg w/ file len, in xml
                
#parse activty log, populate users list, 
#should be started with a port number
print "press ctrl +z to quit"
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  #code from python howto socketprogram
s.bind(('localhost', int(sys.argv[1])))                #minor edits by me
listofusers = []
s.listen(5)
while 1:
    sock, addr = s.accept()
    while True:
        print "Connected to", addr
        ct = clientHandler(sock, addr, listofusers)
        print "thread creating"
        client = threading.Thread(None, ct.run)
        ct.threadName(client.getName())
        print "starting thread"
        client.start()
        break
