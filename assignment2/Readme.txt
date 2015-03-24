Assignment 2 Computer Engineering 401 Network security

Spring 2015.  Peer to Peer OSN.

Everything but search works correctly on the server/client side.  Regular expressions not working as intended.

The client set up and listen to a a UDP socket, for incoming UDP traffic,
this udp socket uses the same port and address of the TCP server socket so that 
the ip and port that the server has recorded for a host can actually reach them,
 otherwise it won't actually do any processes.

This is a set up with a seperate process thread, that spins off threads handling the problems presented.

I feel that a UI might help this because as a text based thing multiple concerrent users talking to one peer could cause issues.

currently chat, wall, entries and post are not handled.

Added ablity to connect to a udp socket by typing in the address.  
This is for testing if the listener thread works as intended.

Neither server or client create or maintain a activity.log 
