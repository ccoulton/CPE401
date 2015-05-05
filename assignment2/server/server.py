import sys
import socket
import string
from time import gmtime, strftime
import os
import re
from threading import Thread
from Crypto.Hash import MD5
from Crypto.PublicKey import RSA
from Crypto import Random

Random_Gen = Random.new().read
keys =  RSA.generate(1024, Random_Gen)

class clientHandler(Thread):
    def __init__(self, socket, addr, users):
        Thread.__init__(self, name = "ClientHndlr")
        self._sock = socket
        self._addr = addr
        self._userList = users
        self._userindex = -1
        cipher = socket.recv(1024)
        self._key = RSA.importKey(cipher)
        
        
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
        userFile.write(name+'\n')
        userFile.close()
        #release lock

    def decrypt(self, data): #serverpub(sendpriv(m))
		string = keys.decrypt(data)  #use private key on message
		string = ''.join(self._key.encrypt(string,0)) #use public key
		splitstring = string.split(' ')
                print string
		msg = splitstring[:-1]
		msgtocheck = ''
		for parts in msg:
			msgtocheck = msgtocheck + parts + ' '
		h = MD5.new()
		h.update(msgtocheck[:-1])
		if int(h.hexdigest(),16) == int(splitstring[-1], 16):
			return string
		else:
			return ''

    def encrypt(self, data):
    	h = MD5.new()
    	h.update(data)
        print data + h.hexdigest()
        cipher = keys.decrypt(data+' '+h.hexdigest())
        cipher = self._key.encrypt(cipher,0)
        return ''.join(cipher)
    
    def run(self):
        while True:
            data = self._sock.recv(1024)
            #print data
            data = self.decrypt(data)
            if (data == ''):
                print "hash failed"
            #ask for lock on activity.log
            #append to activity.log
            sdata = data.split(' ')
            
            if sdata[0].find('REGISTER') != -1:
                outstr = "ACK "+sdata[1]+" "+self._addr[0]+" "+repr(self._addr[1])
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
                    self._userList[userindex][3] = self._key
                    #release lock
                    #self.printUsers()
                    self._userindex = userindex
                    print self._sock.getpeername()
                    outstr = "ACK "+sdata[1]+ " "+self._addr[0]+" "+repr(self._addr[1])
                else:
                    outstr = "ERR "+sdata[1]+" Try registering"
                    #aqqurie lock on error.log
                    #record error
                    #release error.log
            
            elif sdata[0].find('QUIT') != -1:
                #check if user ip matches on file
                pcktaddr = self._sock.getpeername()
                if sdata[1] == self._userList[self._userindex][0] and pcktaddr == self._userList[self._userindex][2]:
                        self._sock.send(self.encrypt("ACK "+sdata[1]))
                        self._sock.shutdown(socket.SHUT_RDWR)
                        self._sock.close()
                        #get lock
                        self._userList[self._userindex][1] = False
                        self._userList[self._userindex][2] = [ ' ', 0]
                        return
                        #release lock
                else:
                    self._sock.send("ERR "+sdata[1]+" not logged out")
                    #get lock
                    #log out if true porse error if not'''
                return   
                
            elif sdata[0].find('UPDATE') != -1:
                #update user's XML profile
                i = 1 #update needs to make sure pull the entire file
                data = data.split(' ', 2) #lets not break up the xml file...
                xmldata = data[2]
                profile = open(self._userList[self._userindex][0]+'.xml', 'a') #create local file
                #get lock maybe
                while True:
                    profile.write(xmldata)  #write file to localfile
                    if i*1024 > sdata[1]:
                        xmldata = self._sock.recv(1024)
                    else:
                        break
                profile.close()         #close 
                #release lock    
                outstr = "SUCCESS "+strftime("%a, %d %b %Y %H:%M:%S +0000", gmtime())
                #self._socket.send("SUCCESS"+timestamp)'''
                
            elif sdata[0].find('SEARCH') != -1:
            	#xmls need to be split to fit inside the encryption key's n
                #search public profile information for keyword sdata[1]
                results = open('SResult.xml', 'a')
                for users in self._userList: #itterate over user list
                    try: 
                        profile = open(users[0]+'.xml', 'r') #try to open all profiles
                        print "profile found for user: ", users[0]
                        #regular expression though profile looking for keyword sdata[1]
                        found = 0
                        for line in profile:
                            if line.find(sdata[1]) != -1:
                                found = 1
                                print "found ", sdata[1]
                        if found == 0:
                            print "no matches found in ",users[0], " profile"
                            profile.close()
                        else:
                            profile.close()
                            profile = open(users[0]+'.xml', 'r')
                            results.write("<result><user>"+users[0]+"</user><ip>"+users[2][0]+"</ip><port>"
                                                      +repr(users[2][1])+"</port>")
                            for line in profile:
                                results.write(line)
                            results.write("</result>")
                            profile.close()
                        #if match is found whole profile, username, and ip address is appended
                        #to results xml file, and send back to the user.  #WTF this is HUGE!
                    except:
                        print "profile not found for user: ", users[0]       
                size = results.tell()
                results.close()
                results = open('SResult.xml', 'r') #probly need to create new file/unquie
                outstr ="RESULTS "+repr(size)+" "
                for line in results:
                    outstr = outstr + line
                results.close()
                os.remove('SResult.xml') #or just clean up the results file.
                #Send whole file to the client.
            if outstr.find('') != -1:
                self._sock.sendall(self.encrypt(outstr))
        
def initUsers():       
    usersFile = open('regusers.txt', 'r')
    usersList = []
    for line in usersFile:
        line = line.replace('\n','')
        
        usersList.append([line, False, [' ', 0], RSA._RSAobj])
    usersFile.close()
    return(usersList)
    
print "MaskTome v2.0 server script started"   
print "press ctrl +c to quit gracefully."
users = initUsers()
TCP = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
pubkey = keys.publickey()
TCP.bind(('localhost', int(sys.argv[1])))
print "listening"
TCP.listen(5)       
#parse activty log, populate users list, 
#should be started with a port number

try: 
    while True:
        sock, addr = TCP.accept()
        print "Connected to", addr
        sock.send(pubkey.exportKey('OpenSSH'))
        Client = clientHandler(sock, addr, users)
        Client.start()
except KeyboardInterrupt:
    TCP.shutdown(socket.SHUT_RDWR)
    TCP.close()
