import sys
import socket
import string

#user class 
    #tuple username first name last name
    #list of friends
    #bool online status
    #tuple of current address
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
