import sys
import socket
import string
import time
import datetime
import re
from threading import Thread

class clientHandler(Thread):
    def __init__(self, socket, addr, users):
        Thread.__init__(self, name = "ClientHndlr")
        self._sock = socket
        self._addr = addr
        self._userList = users
        self._userindex = -1
        
    def printUsers(self):
        for user in self._userList:
            print user
               
    def checkUsers(self, name):
        i = 0
        for users in self._userList:
            if users[0].find(name) == 0: #should be checking if it takes the whole
                return i                 #string not just if it starts with the same
            i += 1                       #string but, this is better than if it just
        return -1                        #contains it as a substring...
        
    def addUser(self, name):
        #get lock
        #add user to list and file
        self._userList.append([name, False, ['', 0]])
        userFile = open('regusers.txt', 'a')
        userFile.write(name)
        userFile.close()
        #release lock
         
    def run(self):
        while True:
            data = self._sock.recv(1024)
            print data
            sdata = data.split(' ')
            
            if sdata[0].find('REGISTER') != -1:
                outstr = "ACK "+sdata[1]+" "+self._addr[0]+" "+repr(self._addr[1])
                self._sock.send(outstr)
                if self.checkUsers(sdata[1]) != -1:
                    print "found user ", sdata[1]
                else:
                    print "user ", sdata[1], " not found adding to member list"
                    self.addUser(sdata[1])
            
            elif sdata[0].find('LOGIN') != -1:
                #check if user is registered
                userindex = self.checkUsers(sdata[1])
                if userindex != -1:
                    #get lock
                    self._userList[userindex][1] = True       #flag user as online
                    self._userList[userindex][2] = self._addr #log user in record IP
                    #release lock
                    #self.printUsers()
                    self._userindex = userindex
                    print self._sock.getpeername()
                    self._sock.send("ACK "+sdata[1]+ " "+self._addr[0]+" "+repr(self._addr[1]))
                else:
                    self._sock.send("ERR "+sdata[1]+" Try registering")
                    #aqqurie lock on error.log
                    #record error
                    #release error.log
            
            elif sdata[0].find('QUIT') != -1:
                #check if user ip matches on file
                pcktaddr = self._sock.getpeername()
                if sdata[1] == self._userList[self._userindex][0] and pcktaddr == self._userList[self._userindex][2]:
                        self._sock.send("ACK "+sdata[1])
                        self._sock.shutdown(socket.SHUT_RDWR)
                        self._sock.close()
                        #get lock
                        self._userList[self._userindex][1] = False
                        #release lock
                else:
                    self._sock.send("ERR "+sdata[1]+" not logged out"
                    #get lock
                    #log out if true porse error if not'''
                return   
                
                '''
            elif sdata[0].find('UPDATE') != -1:
                #check user's ip, if correct
                #update user's XML profile
                self._sock.makefile(sdata[1]) #makefile([mode[, buffersize]])
                #self._socket.send("SUCCESS"+timestamp)'''
                '''
            elif sdata[0].find('SEARCH') != -1:
                #search public profile information for keyword sdata[1]
                #self._socket.send("RESULTS"+xml.len+xml)'''
        
def initUsers():       
    usersFile = open('regusers.txt', 'r')
    usersList = []
    for line in usersFile:
        line = line.replace('\n','')
        usersList.append([line, False, [' ', 0]])
    usersFile.close()
    return(usersList)
print "MaskTome v2.0 server script started"   
print "press ctrl +c to quit gracefully."
users = initUsers()
TCP = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
TCP.bind(('localhost', int(sys.argv[1])))
TCP.listen(5)       
#parse activty log, populate users list, 
#should be started with a port number

try: 
    while True:
        sock, addr = TCP.accept()
        print "Connected to", addr
        Client = clientHandler(sock, addr, users)
        Client.start()
except KeyboardInterrupt:
    TCP.shutdown(socket.SHUT_RDWR)
    TCP.close()
