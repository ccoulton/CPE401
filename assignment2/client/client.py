import sys
import socket
import string
import os
import threading
import time
from Crypto.PublicKey import RSA
from Crypto import Random
import Crypto.Hash
from Crypto.Cipher import PKCS1_v1_5

username = sys.argv[1]
host = sys.argv[2]
host_port = int(sys.argv[3])

class UDPconnectionlistener(threading.Thread):
    def __init__(self, socket):
        threading.Thread.__init__(self, name = "UDPconn")
        self._sock = socket
        self._addr = socket.getsockname()
        self.peers = []
        
    def run(self):
        print "UDP waiting for connection..."
        while 1:
            data, addr = self._sock.recvfrom(1024)
            print "Connect from ", addr
            #spin off udp handler thread
            Handler = UDPHandler(self._sock, data, addr, self.peers)
            #start udp handler
            Handler.start()
            
    def stop(self):
        self._sock.shutdown(socket.SHUT_RDWR)
        self._sock.close()
        
class UDPHandler(threading.Thread):
    def __init__(self, socket, data, addr,  peerlist):
        #print "connection from ", addr, " sent ", data
        threading.Thread.__init__(self, name = "peerhndl")
        self.data = data
        self._addr = addr
        self._peers = peerlist
        self._sock = socket
        
    def run(self):
        sdata = self.data.split(' ')
        #print self.data
        #output = "Connected to "+ self._addr[0]+" "+repr(self._addr[1])
        #self._sock.sendto(output, self._addr)
        if sdata[0].find('FRIEND') != -1:
            self.Friend(sdata[1], self._addr)
        elif sdata[0].find('CHAT')!= -1:
            #chat response
            self.Chat()
        elif sdata[0].find('ACCEPT')!= -1:
            self.Accept()
        elif sdata[0].find('REJECT')!= -1:
            self.Reject()
        elif sdata[0].find('DELIVERED')!= -1:
            self.Delivered()
        elif sdata[0].find('HI')!= -1:
            self.HIhdlr(sdata[1], self._addr)
        #add sender of hi to peer list
        elif sdata[0].find('ENTRIES')!= -1:
            self.Entries()
        elif sdata[0].find('POST')!= -1:
            self.Post()
        
    def Friend(self, user, addr):
        choice = ''
        while True:
            choice = raw_input(user+' has sent you a friend request what is your response (A)ccept, or (R)eject? ')
            choice = choice.lower()
            if   choice[0] == 'a':
                print "you have accepted ", user,"'s request"
                #send accept message
                self._peers.append(user, self._sock.getpeername())
                output = "ACCEPT "
                break
            elif choice[0] == 'r':
                print "You have choosen to reject ", user,"'s request"
                #send reject message
                output = "REJECT "
                break
            else:
                print "incorrect response"
        output = output+username
        self._sock.sendto(output, self._addr)
        
    def Chat(self):
        sdata = self.data.split(' ')
        #packet structure
        #CHAT USERNAME counter msg
        output = "DELIVERED "+username+sdata[3]
        counter = sdata[3]+1
        self._sock.sendto(output, self._addr) #this should close the thread waiting for delivered
        #self._sock.
        
                
        #send back
        #delievered username counter msg try 3 times every 30 seconds
        pass
    
    def Entries(self):
        pass
        
    def Accept(self):
        pass
       
    def Reject(self):
        pass
    
    def Delievered(self):
        pass
        
    def Post(self):
        pass
def encrypt(inString):
    cipher = keys.decrypt(inString)
    cipher = serverpub.encrypt(cipher,0)
    return ''.join(cipher)

def decrypt(inString):
    cipher = keys.decrypt(inString)
    cipher = serverpub.encrypt(cipher,0)
    return ''.join(cipher)

def connectTCP():
    TCPsock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    TCPsock.connect((host, host_port))
    return(TCPsock)
    
def connectUDP(address):
    #udp connection
    UDPsock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    UDPsock.bind((address[0], address[1]))
    #server = (udphost, udp_port)
    return(UDPsock)
    
#login function
def Login(server):
    string = "LOGIN " + username
    server.send(encrypt(string))
    data = decrypt(server.recv(1024))
    print "got msg ", data, "from server"
    info = data.split(' ') #ack username ip port
    #return(server.getpeername())

def Update(server):
    inputString = ''
    while inputString.find('.xml') == -1:
        inputString = raw_input("Please input your profile file name (in xml): ")
    profile = open(inputString, 'r') #open profile
    profile.seek(0, os.SEEK_END) #find file end so we can find the size of the file
    size = profile.tell()        #size of file
    profile.close()              #close profile so we can start at the beginning
    profile = open(inputString, 'r')
    string = "UPDATE "+repr(size)+' '+profile.read(size)
    server.sendall(encrypt(string))
    data = decrypt(server.recv(1024))
    print data
    return
    
def Quit(server):
    string = "QUIT " +username
    server.send(encrypt(string))
    data = decrypt(server.recv(1024))
    data = data.split(' ')
    if data[0] == "ACK":
        print username, " logged out shuting connection"
        server.shutdown(socket.SHUT_WR)
        server.close()
        return
    else:
        print "not logged out IP/Username incorrect"
        #print to error.log
        return
       
#register function
def Register(server):
    input_string = raw_input('Enter your first and last name seperated by space: ')
    firstlast = input_string.split(' ')
    string = "REGISTER " + username + " " + firstlast[0] + " " + firstlast[1]
    server.send(encrypt(string))
    data = decrypt(server.recv(1024))
    print "got msg", data, "from server"
    
def Chat(server): #in the slides from class modified probly....
    #connect to server.
    #CHAT USERNAME Counter message
    '''#client side
    print server.recv(1024)
    while True:
        msg = raw_input('> ')
        if not message:
            return
        server.send(msg + '\n')
        reply = server.recv(1024)
        if not reply:
            print 'server discon'
            return
        print reply
    server.close()'''
    pass
    
def Friend(server):
    pass
    
def UDPConnecttest(UDP):
    ipPort = raw_input("please input a address and port seperated by a space: ")
    ipPort = ipPort.split(' ')
    addr = (ipPort[0], int(ipPort[1]))
    UDP.sendto("test", addr)
    
def Search(server):
    keyword = raw_input("please enter a keyword to search on all profiles: ")
    server.send(encrypt("SEARCH "+keyword))
    results = open("results"+keyword+".xml", 'a')
    data = decrypt(server.recv(1024))
    print data
    data = data.split(' ', 2)
    written = 0
    size = int(data[1])
    if size == 0:
        print "no data found"
        return
    else:
        xmldata = data[2]
        while written < size:
            results.write(xmldata)
            written = written + 1024
            if written < size:
                xmldata = decrypt(server.recv(1024))
        
#sys.argv is filename, arg1, .... , argn
#sys.argv should be User ID/ServerIP/Server port
choice = 'n'
TCPsock = connectTCP()

#recieve key create keys and return encrypted key
serverkeystring = TCPsock.recv(1024) #get key
serverpub = RSA.importKey(serverkeystring) #import it into an RSA object

generator = Random.new().read #gen new randomnum 
keys = RSA.generate(1024, generator) #create keys
pubkey = keys.publickey() #get our pubkey
TCPsock.send(pubkey.exportKey('OpenSSH'))
#start UDP listener
addr = TCPsock.getsockname()
UDPsock = connectUDP(addr)
UDPreciever = UDPconnectionlistener(UDPsock)
UDPreciever.start()

#client needs to open up a udp server thread to handle incoming udp peer connections
#that thread needs to interupt when it has somthing connect and handle it's process
#possiably even breaking off threads of it's own to handle the different things it
#has going on friend requests/chats etc
#print addr
while choice[0] != 'q':
    print "What action would you like to take on MaskTome v2.0?"
    print "Register New user (r)"
            #Register(s, username)
            #send server userid user-name and user-last 
            #retry after 10, and report in error log if all 3 fail
    print "Update public profile(u)"
            #send file-len xml file to server
    print "Login (l)\nQuit (q)"
            #login/quit to server with user id
                #ip/port recored/removed
    print "Friend (f)"
        #request friend of user, confirm or reject user friend req
    print "Chat (c)\nPost (p)\nEntries (e)"
        #send chat to user, post group msg, and get entries from tim
    print "Search Public Profiles (s)"
            #search with keyword Regular expressions ho!
                #recieve results file of len in xml
    input_string = raw_input('Enter your choice: ')
    choice = input_string[0]
    #append action to activity.log username/timestamp etc
    if choice == 'r':   #server tcp recieve ack
        Register(TCPsock)
    elif choice == 'u': #server tcp
        Update(TCPsock)
    elif choice == 'l': #server tcp
        Login(TCPsock)
    elif choice == 'q': #server tcp
        Quit(TCPsock)
    elif choice == 'f': #client udp
        Friend(UDPsock)
    #elif choice == 'c': #client udp #not needed because this will be handled
    #elif choice == 'j': #client udp''' #when the friend message comes in from thread
    elif choice == 'c': #client udp
        UDPConnecttest(UDPsock)     
    #elif choice == 'p': #client udp    
    #elif choice == 'e': #client udp
    elif choice == 's': #server tcp returns result xml
        Search(TCPsock)
    
'''       
#udp server    
UDP = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
UDP.bind(('127.0.0.1', 11111))
while True:
        data, addr = UDP.recvfrom(1024)
        print "Connect from", addr
        incoming = data.split(' ')
        output = "ACK " + incoming[1] + " " + addr[0] + " " + repr(addr[1])
        UDP.sendto(output, addr)
    
    )'''
