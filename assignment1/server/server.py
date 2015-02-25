import sys
from socket import socket, AF_INET, SOCK_STREAM
#should be started with a port number

while 1:
    s = socket(AF_INET, SOCK_STREAM)
    s.bind(('127.0.0.1', int(sys.argv[1])))
    s.listen(5)
    
    while True:
        sock, addr = s.accept()
        print "Connected to", addr
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
