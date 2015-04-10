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
        let mainApp = UIApplication.sharedApplication().delegate as AppDelegate
        mainApp.TCPconnect(Host, host_Port: Port)
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

    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
    }

}

class GetReginfo: UIViewController{
    
    let mainApp = UIApplication.sharedApplication().delegate as AppDelegate
    
    
    @IBOutlet weak var FName: UITextField!
    @IBOutlet weak var LName: UITextField!
    @IBAction func Register(sender:UIButton){
        var temp: NSString
        temp = "REGISTER "
        var buffer: NSString
        buffer = temp.stringByAppendingString(self.mainApp.UserName! as String) //add user name
        buffer = buffer.stringByAppendingString(" ")  //add a space
        //wait till registar button returns
        buffer = buffer.stringByAppendingString(self.FName.text as String)  //add first name to string
        buffer = buffer.stringByAppendingString(" ")
        buffer = buffer.stringByAppendingString(self.LName.text as String)  //add last name to string
        let data: NSData = buffer.dataUsingEncoding(NSUTF8StringEncoding)!
        mainApp.TCPStreamOut?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        //read from tcpstreamin
        //check for ack package
        //mainApp.ReadFromTCP()
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
    let mainApp = UIApplication.sharedApplication().delegate as AppDelegate
    var RegInput: GetReginfo?
    //TCP MODUALS
    
    @IBAction func Login(sender: UIButton) {
        var temp: NSString
        temp = "LOGIN "
        var buffer: NSString
        buffer = temp.stringByAppendingString(self.mainApp.UserName! as String)
        let data: NSData = buffer.dataUsingEncoding(NSUTF8StringEncoding)!
        //write to socket
        mainApp.TCPStreamOut?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        //mainApp.ReadFromTCP()
        //open master UDP socket
        //send HI message to Peers
        //make list of peers and set up ports for each
        //check that the message whent though
    }
    
    @IBAction func Quit(sender:UIButton){
        //close inputstream and clean up
        mainApp.TCPStreamIn?.close()
        mainApp.TCPStreamIn?.removeFromRunLoop((NSRunLoop.currentRunLoop()), forMode: NSDefaultRunLoopMode)
        mainApp.TCPStreamIn?.delegate = nil
        //send out quit message to server
        var temp: NSString
        temp = "QUIT "
        temp = temp.stringByAppendingString(self.mainApp.UserName! as String)
        let data: NSData = temp.dataUsingEncoding(NSUTF8StringEncoding)!
        mainApp.TCPStreamOut?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        //close output stream and clean up after self
        mainApp.TCPStreamOut?.close()
        mainApp.TCPStreamOut?.removeFromRunLoop((NSRunLoop.currentRunLoop()), forMode: NSDefaultRunLoopMode)
        mainApp.TCPStreamOut?.delegate = nil
        //close UDP sockets
        //close master UDP socket
    }
    
    
    @IBAction func Update(sender:UIButton){
        //ask for xml file
        //put in "UPDATE "
        //append xml file to string
        //check for bytes avaiable
        //send on socket
        //check that the file has been sent
        //read on socket for success
    }
    
    @IBAction func Search(sender:UIButton){
        //keyword is in self.Keyword
        if self.Keyword.text == nil{//if textbox was empty
            return}
        else{
            //append SEARCH and keyword to data
            var temp: NSString
            temp = "SEARCH "
            temp = temp.stringByAppendingString(self.Keyword.text)
            let data: NSData = temp.dataUsingEncoding(NSUTF8StringEncoding)!
            //write to socket
            mainApp.TCPStreamOut?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
            //read from socket
            //mainApp.ReadFromTCP()
            //display resulting xml
        }
        
    }
    
    @IBAction func Chat(sender:UIButton){
        //create new view controller
        //ask for which peer to talk to
        
        //send "chat
    }
    
    @IBAction func Friend(sender: UIButton){
        //ask user for friendship
        //write "FRIEND "+UserName
        //let master UDP socket handle response
    }
    
    @IBAction func Post(sender: UIButton){
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
    }
    
    @IBAction func Entries(sender: UIButton){
        //get all wall posts since time in reverse 
        //chronological order
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    	}
    
    }

