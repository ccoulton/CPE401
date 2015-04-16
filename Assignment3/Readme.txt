Assignment 3 Phone2phone OSN

Programmed in Swift using Xcode 6.3, and on iOS 8.0+

Tcp sockets to server are handled update is just hanging but could be handled

Had not quite gotten dictionaries to parse the xml results file to work
Udp was much harder than Expected, bsd sockets in swift are a total pain

many attempts to get it bound to the same port as the tcp where attempted
and because of that other bindings and listening where not created.

The idea would be have a udp socket listener for each peer such that when a peer
would connect to the main listener another socket would open and connect back to
that peer on another port such that comuncation could happen without interupting
new connections to the "masterUDP" 
