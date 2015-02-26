import sys
import socket
#sys.argv is filename, arg1, .... , argn
#sys.argv should be User ID/ServerIP/Server port
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
username = sys.argv[1]
host = sys.argv[2]
host_port = int(sys.argv[3])
s.connect((host, host_port))

choice = 'n'

while choice[0] != 'q':
    print "What action would you like to take on MaskTome?\n"
    print "Register New user (r)\n"
            #Register(s, username)
            #send server userid user-name and user-last 
            #retry after 10, and report in error log if all 3 fail
    print "Update public profile(u)\n"
            #send file-len xml file to server
    print "Login (l)\nQuit (q)\n"
            #login/quit to server with user id
                #ip/port recored/removed
    print "Friend (f)\nConfirm (c)\nReject(j)\n"
        #request friend of user, confirm or reject user friend req
    print "Chat (h)\nPost (p)\nEntries (e)\n"
        #send chat to user, post group msg, and get entries from tim
    print "Search Public Profiles (s)\n"
            #search with keyword Regular expressions ho!
                #recieve results file of len in xml
    input_string = input('Enter your choice: ')
    choice = input_string[0]
    
def Register(s, username):
    s.sendall("register", username)
    
