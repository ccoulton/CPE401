//
//  ViewController.swift
//  Assignment3
//
//  Created by Charles Coulton on 4/6/15.
//  Copyright (c) 2015 Charles Coulton. All rights reserved.
//

import UIKit
import CoreFoundation
//import bridge

class InputScreen: UIViewController{

    @IBOutlet weak var Host_Port: UITextField!
    @IBOutlet weak var Host_Name: UITextField!
    @IBOutlet weak var User_Name: UITextField!
    @IBAction func Host_connect(sender: UIButton) {
        var Port: UInt32
        var Host: NSString
        Host = self.Host_Name.text
        /*var addr: sockaddr
        
        TCPsock = socket(AF_INET, SOCK_STREAM)
        //bind(TCPsock, addr, <#socklen_t#>)*/
        if let number = self.Host_Port.text.toInt()
            {
            Port = UInt32(number)
            }
        else{
            print(self.Host_Port.text)
            Port = 0
        }
        //
        let mainApp = UIApplication.sharedApplication().delegate as! AppDelegate
        mainApp.TCPconnect(Host, host_Port: Port)
        var serverPub: NSString = mainApp.ReadFromTCP()
        NSLog(serverPub as String)
        //split the key off of ssh-rsa 'key'
        //create key encrypt with serverpub key
        //mainApp.TCPStreamOut.write(client pub key, maxLength: data.length)
        mainApp.UserName = self.User_Name.text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
    //}

}

class GetReginfo: UIViewController{
    
    let mainApp = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    @IBOutlet weak var FName: UITextField!
    @IBOutlet weak var LName: UITextField!
    @IBAction func Register(sender:UIButton){
		sender.enabled = false;    
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
		    var temp: NSString = NSString(format: "%@%@%@%@%@%@", 
		    						"REGISTER ", self.mainApp.UserName!
		    						, " ", self.FName.text
		    						, " ", self.LName.text)
		    let data: NSData = temp.dataUsingEncoding(NSUTF8StringEncoding)!
		    self.mainApp.TCPStreamOut?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
		    //read from tcpstreamin
		    //check for ack package
		    var Ack: NSString = self.mainApp.ReadFromTCP()
		    //ack split on spaces.
		    //var array: NSArray _n componentsSeparatedByString: " "
		    sender.enabled = true; //enable button
		})
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}

class menuScreen: UIViewController{
    @IBOutlet weak var Keyword: UITextField!
    let mainApp = UIApplication.sharedApplication().delegate as! AppDelegate
    var RegInput: GetReginfo?
    //TCP MODUALS
    
    @IBAction func Login(sender: UIButton) {
		sender.enabled = false;  //disable button  
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			var temp: NSString = NSString(format: "%@%@", "LOGIN ", self.mainApp.UserName!)
			let data: NSData = temp.dataUsingEncoding(NSUTF8StringEncoding)!
			//write to socket
			self.mainApp.TCPStreamOut?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
			//get ack from tpc socket
		   	var ack: NSString = self.mainApp.ReadFromTCP()
		   	//split ack into ack username ip, and port to set up udp
		   	var SplitAck: NSArray = ack.componentsSeparatedByString(" ")
			//ack username ip port
			self.mainApp.MainIP = (SplitAck[2] as! NSString)
            var tempPort: NSString = SplitAck[3] as! NSString
            self.mainApp.MainPort = tempPort.intValue
            //open master UDP socket
            self.mainApp.ConnectUDP()
			//make list of peers and set up ports for each
			//send HI message to Peers
			sender.enabled = true; //enable button
		})
    }
    
    @IBAction func Quit(sender:UIButton){
        //close inputstream and clean up
        sender.enabled = false;   //lock button
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        	//close socket 
		    self.mainApp.TCPStreamIn?.close()
		    //remove from runloop
		    self.mainApp.TCPStreamIn?.removeFromRunLoop((NSRunLoop.currentRunLoop()), forMode: NSDefaultRunLoopMode)
		    //set to nil to close it out
		    self.mainApp.TCPStreamIn?.delegate = nil
		    //send out quit message to server
		    var temp: NSString = NSString(format: "%@%@", "QUIT ", self.mainApp.UserName!)
		    let data: NSData = temp.dataUsingEncoding(NSUTF8StringEncoding)!
		    self.mainApp.TCPStreamOut?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
		    //close output stream and clean up after self
		    self.mainApp.TCPStreamOut?.close()
		    self.mainApp.TCPStreamOut?.removeFromRunLoop((NSRunLoop.currentRunLoop()), forMode: NSDefaultRunLoopMode)
		    self.mainApp.TCPStreamOut?.delegate = nil
        //close UDP sockets
        //close master UDP socket
        	sender.enabled = true; //enable button
		})
    }
    
    @IBAction func Update(sender:UIButton){
    	sender.enabled = false;    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
		    //ask for xml file
		    //put in "UPDATE ", file size, xml
		    var temp: NSString = NSString(format: "%@", "UPDATE "/*, XMLfile*/)
		    //check for bytes avaiable
		    //send on socket
		    let data: NSData = temp.dataUsingEncoding(NSUTF8StringEncoding)!
		    self.mainApp.TCPStreamOut?.write(UnsafePointer<UInt8>(data.bytes), 
		    											maxLength: data.length)
		    //check that the file has been sent
		    //read on socket for success
		    //var ack: NSString = self.mainApp.ReadFromTCP()
		    //var result: NSArray = ack.componentsSeparatedByString(" ")//ack.split()
		    /*if result[0] == "SUCESS"{ // good
		    }else{
		    	//bad?
		    }*/
        	sender.enabled = true; //enable button
		})
    }
    
    @IBAction func Search(sender:UIButton){
        //keyword is in self.Keyword
        if self.Keyword.text == nil{//if textbox was empty
            return}
        else{
            sender.enabled = false;
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //append SEARCH and keyword to data
                var temp: NSString
                temp = NSString(format: "%@%@", "SEARCH ", self.Keyword.text)
                let data: NSData = temp.dataUsingEncoding(NSUTF8StringEncoding)!
                //write to socket
                self.mainApp.TCPStreamOut?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
                //read from socket
               	var Result: NSString = self.mainApp.ReadFromTCP()
                //display resulting xml
                var Result_Array: NSArray = Result.componentsSeparatedByString(" ")
                //pckt = RESULTS Size XML so the xml will be evertying after 2
             	//parse xml into dictonary 
                sender.enabled = true;
            })
        }
    }
    
    @IBAction func Chat(sender:UIButton){
    	sender.enabled = false;    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        //create new view controller
        //ask for which peer to talk to
        	var temp: NSString = NSString(format: "%@%@%@", "CHAT ", self.mainApp.UserName!, " "/*, chatStream*/)
        	//get peer's master udp and chat stream
        	let data: NSData = temp.dataUsingEncoding(NSUTF8StringEncoding)!
        	//send to udpsocket
        	//self.mainApp.peersudp.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length) //send to peerudp
        	sender.enabled = true; //enable button
		})
    }
    
    @IBAction func Friend(sender: UIButton){
    	sender.enabled = false;    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        //ask user for friendship
        	var temp: NSString = NSString(format: "%@%@", "FRIEND ", self.mainApp.UserName!)
        	let data: NSData = temp.dataUsingEncoding(NSUTF8StringEncoding)!
        //peer sends back REJECT or ACCEPT out if accept get new udp socket for that peer
        //if reject don't make a new udp peer
        //let master UDP socket handle response
        	sender.enabled = true; //enable button
		})
    }
    
    @IBAction func Post(sender: UIButton){
    	sender.enabled = false;    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        	var temp: NSString = NSString(format: "%@%@%@", "POST ", self.mainApp.UserName!, " "/*, XMLfile*/)
        //push content as xml file marked for friends
        //friends of friends or public
        //if public send to server to update profile
            //and online friends, who flood it to all
            //friends online replacing userid so that
            //sent friend doesn't get it, check from
        //if fof send to friends changing the flag
            //so it's not broadcast again
            //change flag to friends 
        //friends flag causes end of transmission
        	sender.enabled = true; //enable button
		})
    }
    
    @IBAction func Entries(sender: UIButton){
    	sender.enabled = false;    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        	var temp: NSString = NSString(format: "%@%@%@", "ENTRIES ", self.mainApp.UserName!, " "/*, timestamp*/)
        //get all wall posts since time in reverse 
        //chronological order
        	sender.enabled = true; //enable button
		})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    	}
    
    }

