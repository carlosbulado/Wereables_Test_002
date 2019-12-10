import UIKit
import Particle_SDK

class ViewController: UIViewController
{
    // MARK: User variables
    let USERNAME = "carlosbulado@gmail.com"
    let PASSWORD = "C4rl0sParticle"
    
    // MARK: Device
    let DEVICE_ID = "220038000447363333343435"
    var myPhoton : ParticleDevice?
    //MARK: IBOutlets
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var mohammadSlider: UISlider!
    @IBOutlet weak var timeSlowsByLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // 1. Initialize the SDK
        ParticleCloud.init()
        
        // 2. Login to your account
        ParticleCloud.sharedInstance().login(withUser: self.USERNAME, password: self.PASSWORD)
        {
            (error:Error?) -> Void in
            if (error != nil)
            {
                // Something went wrong!
                print("Wrong credentials or as! ParticleCompletionBlock no internet connectivity, please try again")
                // Print out more detailed information
                print(error?.localizedDescription)
            }
            else
            {
                print("Login success!")

                // try to get the device
                self.getDeviceFromCloud()
            }
        } // end login
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Get Device from Cloud
    // Gets the device from the Particle Cloud
    // and sets the global device variable
    func getDeviceFromCloud()
    {
        ParticleCloud.sharedInstance().getDevice(self.DEVICE_ID) { (device:ParticleDevice?, error:Error?) in
            
            if (error != nil)
            {
                print("Could not get device")
                print(error?.localizedDescription)
                return
            }
            else
            {
                print("Got photon from cloud: \(device!.id)")
                self.myPhoton = device
                
                // subscribe to events
                self.subscribeToParticleEvents()
            }
            
        } // end getDevice()
    }
    
    
    //MARK: Subscribe to "playerChoice" events on Particle
    func subscribeToParticleEvents()
    {
        ParticleCloud.sharedInstance().subscribeToDeviceEvents(
            //withPrefix: "sideShape",
            withPrefix: nil,
            deviceID:self.DEVICE_ID,
            handler: {
                (event :ParticleEvent?, error : Error?) in
            
            if let _ = error {
                print("could not subscribe to events")
            } else {
                print("got event with data \(event)")
                let choice = (event?.data)!
                
                self.updateScreen(choice: "\(choice)")
            }
        })
    }
    
    func updateScreen(choice : String)
    {
        DispatchQueue.global(qos: .utility).async {
            DispatchQueue.main.async {
                // now update UI on main thread
                self.numberLabel.text = choice
            }
        }
    }
    
    //MARK: Class custom functions
    func callParticleFunc(functionName: String, arg: [String])
    {
        myPhoton!.callFunction(functionName, withArguments: arg) { (resultCode : NSNumber?, error : Error?) -> Void in
            if (error == nil) { }
        }
    }
    @IBAction func startMonitoringClick(_ sender: Any)
    {
        self.callParticleFunc(functionName: "init", arg: []);
    }

    @IBAction func stopMonitoringClick(_ sender: Any)
    {
        self.callParticleFunc(functionName: "stop", arg: []);
    }
    
    @IBAction func onSliderChange(_ sender: Any)
    {
        let newValueForSlowDown = Int(self.mohammadSlider.value * 10)
        self.timeSlowsByLabel.text = "TIME SLOWS DOWN BY: \(newValueForSlowDown)"
        self.callParticleFunc(functionName: "setTimeSlowDown", arg: ["\(newValueForSlowDown)"]);
    }
}
