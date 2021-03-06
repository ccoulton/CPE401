//
//  AppDelegate.swift
//  Assignment3
//
//  Created by Charles Coulton on 4/6/15.
//  Copyright (c) 2015 Charles Coulton. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import Security
//import sys/socket
//import netinet/in

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NSStreamDelegate {
	var MainIP: NSString?
	var MainPort: Int32?
    var window: UIWindow?
    var LoginInfo: InputScreen?
    var TCPStreamIn: NSInputStream?
    var TCPStreamOut: NSOutputStream?
    var Menu: menuScreen?
    var UserName: NSString?
    var MasterUDP: CFSocket?
    var serverPub: SecKeyRef?
    var clientPub: SecKeyRef?
    var clientPrv: SecKeyRef?
    //var Peerlist: CFSocket = CFSocket(length: 15)?
    //var master UDP socket
    //list of UDP peers with sockets.
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window?.makeKeyAndVisible()
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "ccunr.Assignment3" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Assignment3", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Assignment3.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext ()
        {
        if let moc = self.managedObjectContext
            {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error)
                {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
                }
            }
        }
        
    
    func TCPconnect(host_IP: NSString, host_Port: UInt32)//->Bool
        {
        var TCPalloc: CFAllocator?
        TCPalloc = kCFAllocatorDefault
        var TCPin: Unmanaged<CFReadStream>?
        var TCPout: Unmanaged<CFWriteStream>?
        //try to connect to server
        CFStreamCreatePairWithSocketToHost(TCPalloc, host_IP, host_Port, &TCPin, &TCPout)
        
        self.TCPStreamOut = TCPout!.takeRetainedValue()
        self.TCPStreamIn = TCPin!.takeRetainedValue()
        self.TCPStreamIn?.delegate = nil
        self.TCPStreamOut?.delegate = nil
        self.TCPStreamIn?.scheduleInRunLoop((NSRunLoop .currentRunLoop()), forMode: NSDefaultRunLoopMode)
        self.TCPStreamOut?.scheduleInRunLoop((NSRunLoop .currentRunLoop()), forMode: NSDefaultRunLoopMode)
        self.TCPStreamIn?.open()
        self.TCPStreamOut?.open()
    }
    
    func sharedApplication() -> AppDelegate{
        return self
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        print(eventCode)
        //switch(eventCode){
        //case :
            if aStream == self.TCPStreamIn{
                self.ReadFromTCP()
            }
        //}
    }
    
    func ReadFromTCP() -> NSString{
        var resultBuffer:NSMutableData = NSMutableData(length: 1024)!
        var bytesRead:Int = 0
        bytesRead = self.TCPStreamIn?.read(UnsafeMutablePointer<UInt8>(resultBuffer.mutableBytes), maxLength: 1024) as Int!
        resultBuffer.length = bytesRead;
        var result = NSString(data: resultBuffer, encoding: NSUTF8StringEncoding)!
        return result
    }
    /*
    func sockaddr_cast(p: ConstUnsafePointer<sockaddr_in>) -> ConstUnsafePointer<sockaddr> {
        return ConstUnsafePointer<sockaddr>(p)
    }*/
    func encryptString(inString: NSString, pubKey: SecKeyRef, privKey: SecKeyRef){// -> NSString{
            //encrypt instring privkey if privkey == none is udp communcation session key
            //encrypt instring pubkey
            //return outstring
    }
    
    //send user name to server that you want to connect to.
    //if that user is online, server will return Kerberos type packets
    //first packet is clientpub(serverpriv(user2ip, user2port, sessionkey)), second is user2pub(serverpriv(client, sessionkey))
    //send second packet to the user2ip:port, then send a packet sessionkey(client)
    //since these are the only packets that the udp master socket should be getting it can just set up sockets for these connections 
    //creating a client name, ip:port and session key for each
    
    func ConnectUDP(){
        var status: Int32 = 0
        var addrHint = addrinfo(
            ai_flags: AI_PASSIVE,
            ai_family: AF_INET,
            ai_socktype: SOCK_DGRAM,
            ai_protocol: 0,
            ai_addrlen: 0,
            ai_canonname: nil,
            ai_addr: nil,
            ai_next: nil)
        
        var serverinfo = UnsafeMutablePointer<addrinfo>(nil)
        
        //status = getaddrinfo(UnsafePointer<Int8>(nil), (UnsafePointer<Int32>(self.MainPort) as! UnsafePointer<Int8>), &addrHint, &serverinfo)
        if status != 0 {return}
        /*if ap_applicationInDebugMode{
            for (var info = severinfo; info != nil; info = info.memory.ai_next){
                
            }
        }*/
        /*
        //from stackoverflow mostly...
        var addr = sockaddr_in()
        memset(&addr, 0, sizeof(sockaddr_in))
        addr.sin_len = UInt8(sizeof(sockaddr_in))
        addr.sin_family = UInt8(AF_INET)
        addr.sin_port = UInt16(self.MainPort!)
        inet_aton(String(self.MainIP!), &addr.sin_addr)
        var MasterAddr: NSData = NSData(bytes: &addr, length: Int(addr.sin_len))
        
        var sock:CInt = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
        //var err = bind(sock, self.sockaddr_cast(&addr), addr.sin_len)
        //CFSocketSignature(protocolFamily: <#Int32#>, socketType: <#Int32#>, protocol: <#Int32#>, address: )
        /*var _test: Unmanaged<CFDataRef>? = nil;
        _test = MasterAddr as! CFDataRef
        var MasterUDPSig: CFSocketSignature = CFSocketSignature()
        MasterUDPSig.protocolFamily = PF_INET
        MasterUDPSig.socketType = SOCK_DGRAM
        MasterUDPSig.address = MasterAddr  //CFDataCreate(nil, UnsafePointer<UInt8>(MasterAddr.bytes), MasterAddr.length)

        self.MasterUDP = CFSocketCreateWithSocketSignature(kCFAllocatorDefault, &MasterUDPSig, 0, nil, nil)*/
    	
        //types required cfsockcreate(alloc, protofam, sock type, proto, callbacktypes, callout, context)
    	//readcallback is called when data is avaiable
    	self.MasterUDP = CFSocketCreateWithNative(kCFAllocatorDefault, sock, 0, nil, nil)
    	if MasterUDP == nil{
    		print("Failed to create")
    		}
    	else{
            //CFSocketSetAddress(self.MasterUDP, MasterAddr)
    		//				  cfsocekt cfdata, cfdata, timeout len
            //CFSocketSendData(self.MasterUDP, MasterAddr, Data, 10)
    		//self.MasterUDP.delegate = self
    		}*/
    		
    }
    //func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
    func UDPListener(){
        print("I HEAR UDP SIGNALS")
    }
    //make master udp listener delegate
        //read check udp status
        //if bytes avaiable
        //recieve from socket
        //parse string for recieved string
        //if WALL pull all data and display xml
        //if reject show reject
        //if accept append peer list and list of udp peers
        //if chat display message and user name
        //if post fof
        //change tag to friends and send to all peers on list
        //if hi add peer's port and create a UDP socket for that peer
        //if friend ask if accept or reject

}
