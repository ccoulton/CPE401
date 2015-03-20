import sys
import socket
import string

username = sys.argv[1]
host = sys.argv[2]
host_port = int(sys.argv[3])

def connectTCP():
    TCPsock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    TCPsock.connect((host, host_port))
    return(TCPsock)
    
def connectUDP(udphost, udp_port, address):
    #udp connection
    UDPsock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    UDPsock.bind((address[0], repr(address[1])))
    server = (udphost, udp_port)
    return(UDPsock)
    
#login function
def Login(server):
    string = "LOGIN " + username
    server.send(string)
    data = server.recv(1024)
    print "got msg ", data, "from server"
    info = data.split(' ') #ack username ip port
    return([info[2], int(info[3])])

def Quit(server):
    string = "QUIT " +username
    server.send(string)
    server.shutdown(socket.SHUT_WR)
    data = server.recv(1024)
    print data
    server.close()
    return
        
#register function
def Register(server):
    input_string = raw_input('Enter your first and last name seperated by space: ')
    firstlast = input_string.split(' ')
    string = "REGISTER " + username + " " + firstlast[0] + " " + firstlast[1]
    server.send(string)
    data = server.recv(1024)
    print "got msg", data, "from server"
        
#sys.argv is filename, arg1, .... , argn
#sys.argv should be User ID/ServerIP/Server port
choice = 'n'
TCPsock = connectTCP()
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
    print "Friend (f)\nConfirm (c)\nReject(j)"
        #request friend of user, confirm or reject user friend req
    print "Chat (h)\nPost (p)\nEntries (e)"
        #send chat to user, post group msg, and get entries from tim
    print "Search Public Profiles (s)"
            #search with keyword Regular expressions ho!
                #recieve results file of len in xml
    input_string = raw_input('Enter your choice: ')
    choice = input_string[0]
    if choice == 'r':   #server tcp recieve ack
        Register(TCPsock)
    #elif choice == 'u': #server tcp 
    elif choice == 'l': #server tcp
        addr = Login(TCPsock)
    elif choice == 'q': #server tcp
        Quit(TCPsock)
    #elif choice == 'f': #client udp
    #elif choice == 'c': #client udp
    #elif choice == 'j': #client udp
    #elif choice == 'h': #client udp
    #elif choice == 'p': #client udp
    #elif choice == 'e': #client udp
    #elif choice == 's': #server tcp returns result xml
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
'''
