//
//  ViewController.swift
//  Flat Weather
//
//  Created by Erica Roy on 11/19/14.
//  Copyright (c) 2014 Erica Roy. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate {
	
	var locationManager = CLLocationManager()
	
    var userLocation : String!
    var userLat : Double!
    var userLong : Double!
    var localCity : String!
    @IBOutlet weak var cityLocationLabel: UILabel!

	@IBOutlet weak var iconView: UIImageView!
	@IBOutlet weak var currentTimeLabel: UILabel!
	@IBOutlet weak var tempLabel: UILabel!
	@IBOutlet weak var tempMax: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var currentSummary: UILabel!
    @IBOutlet weak var ozoneText: UILabel!
    @IBOutlet weak var ozoneLabel: UIView!
  

    
	

override func viewDidLoad() {
		
    super.viewDidLoad()
    
     //Save for later, put in own function to switch between right now its showing snow
    let emitterLayer = CAEmitterLayer()
    
    emitterLayer.emitterPosition = CGPoint(x: -5, y: 20)
    
    let cell = CAEmitterCell()
    cell.birthRate = 5
    cell.lifetime = 10
    cell.velocity = 50
    cell.scale = 0.05
    
    cell.emissionRange = CGFloat.pi * 2.0
    cell.contents = UIImage(named: "snow.png")!.cgImage
    
    emitterLayer.emitterCells = [cell]
    
    view.layer.addSublayer(emitterLayer)
 
    initLocation()
    
  
    
 
}


override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
}

//shake it shake it to get data
override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if(event?.subtype == UIEventSubtype.motionShake){
            
            initLocation()
           // loadingIndicator.hidden = false
           // loadingIndicator.startAnimating()
        }
        
}
    
func initLocation(){
    
    //check to see if location services is enabled
    if CLLocationManager .locationServicesEnabled(){
        print("Location Services Enabled")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    
      
 
    
        
    
    }else{
        print("not enabled")
        let alert = UIAlertController(title: "Location Services Disabled",
            message: "Please enable Location Services",
            preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK",
            style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        
    }
}
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
{
        let location:CLLocation = locations[locations.count-1]

        if (location.horizontalAccuracy > 0) {
      
        self.userLong = (location.coordinate.longitude)
        self.userLat = (location.coordinate.latitude)
        //remove space silly
        self.userLocation = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        print(userLocation)
        getCurrentWeatherData(userLocation)
        locationManager.stopUpdatingLocation()

            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
							
                
                if error != nil {
                  
                    return
                }
                
                if (placemarks?.count)! > 0 {
                    let pm = placemarks?[0]
                    self.localCity = (pm?.locality)
                    self.cityLocationLabel.text = self.localCity
                    
                    
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            })
    }
}
    

func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    let state = CLLocationManager.authorizationStatus()
    if(state == CLAuthorizationStatus.denied){
        
        let alert = UIAlertController(title: "Denied",
            message: "Permission Denied, please enable location services",
            preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK",
            style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        locationManager.stopUpdatingLocation()

        
    }

            let alert = UIAlertController(title: "Error",
            message: "Trouble retrieving location",
            preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK",
            style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        locationManager.stopUpdatingLocation()

    
    
}

  

    func getCurrentWeatherData(_ userLocation: String) -> Void
    {
        var skyKey = ""
        //should probably cache this
        
        
        let path = Bundle.main.path(forResource: "keys", ofType: "plist")
        let keys = NSDictionary(contentsOfFile: path!)
        skyKey = keys!.object(forKey: "darkskykey") as! String
        
        let baseURL = URL(string: "https://api.darksky.net/forecast/\(skyKey)/")
        let forecastURL = URL(string: (userLocation), relativeTo: baseURL)
        
        let sharedSession = URLSession.shared
        let task = sharedSession.dataTask(with: forecastURL!) {
            (data, response, error) in
            
            //if let replace
            guard error == nil else {
                print(error!)
                return
            }
           
            guard let dataObject = data else {
                print("Oops no data")
                return
            }
            do {
                let weatherDictionary  = try JSONSerialization.jsonObject(with: dataObject, options: []) as! NSDictionary
                //print out the json response
                print(weatherDictionary)
                
                let currentWeather = Current(weatherDictionary: weatherDictionary)
                print(currentWeather)
                DispatchQueue.main.async {
                    // Update UI
                    
                    self.tempLabel.text = "\(Int(currentWeather.temperature!))"
                    self.currentSummary.text = "\(currentWeather.todaySummary!)"
                  
                 
                    self.iconView.image = currentWeather.icon!
                    self.currentTimeLabel.text = "\(currentWeather.currentTime!)"
                    
                    
                    /*
                    switch currentWeather.ozone {
                    case 0...50:
                        print("Nice")
                        self.ozoneLabel.backgroundColor = UIColor.green
                        self.ozoneText.text = "Good"
                    case 51...100:
                        print("mod")
                        self.ozoneLabel.backgroundColor = UIColor.yellow
                        self.ozoneText.text = "Moderate"
                    case 101...150:
                        print("maybe")
                        self.ozoneLabel.backgroundColor = UIColor.orange
                        self.ozoneText.text = "Unhealthy"
                    case 151...200:
                        print("bad")
                        self.ozoneLabel.backgroundColor = UIColor.red
                        self.ozoneText.text = "Unhealthy"
                    case 201...300:
                        print("yeah")
                        self.ozoneLabel.backgroundColor = UIColor.purple
                        self.ozoneText.text = "Very Unhealthy"
                    case 301...500:
                        print("hazard")
                        self.ozoneLabel.backgroundColor = UIColor.magenta
                        self.ozoneText.text = "Hazardous"
                    default:
                        print("blah")
                    }
                    print(currentWeather.ozone)
                    */
                }
                
            
              
               
            } catch  {
                print(error)
                return
            }
        }
        task.resume()
     
    }

    
    //end function
    
    
    func registerMessage() {
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
    }
    
    func scheduleMessage() {
        
    }
    
    //Change Background Image depending on temp
    //
    //Add Things to Do according to temp
}



