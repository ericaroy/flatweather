//
//  current.swift
//  Flat Weather
//
//  Created by Erica Roy on 11/22/14.
//  Copyright (c) 2014 Erica Roy. All rights reserved.
//

import Foundation
import UIKit

struct Current {
    
    var currentTime : String?
    var temperature: Float?
	var currentAlert : String?
    var icon: UIImage?
    var ozone: Float

   
    
    init(weatherDictionary: NSDictionary){
			
        let currentWeather: NSDictionary = weatherDictionary["currently"] as! NSDictionary
        temperature = currentWeather["temperature"] as? Float
        ozone = currentWeather["ozone"]as! Float
        print(ozone)
        //icon = currentWeather["icon"] as String
        let currentTimeIntValue = currentWeather["time"] as! Int
        currentTime = dateStringFromUnixTime(unixTime: currentTimeIntValue)
        let iconString = currentWeather["icon"] as! String
        icon = weatherIconFromString(stringIcon: iconString)
   
    }
	
	func dateStringFromUnixTime(unixTime: Int) -> String{
	
		let timeInSeconds = TimeInterval(unixTime)
		let weatherDate = NSDate(timeIntervalSince1970: timeInSeconds)
		let dateFormatter = DateFormatter()
		dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: NSDate() as Date)
		return dateFormatter.string(from: weatherDate as Date)
        
        
	
	}
    func dayStringFromUnixTime(unixTime: Int) -> String{
        
        let timeInSeconds = TimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSeconds)
        
        
        let dateFormatter2 = DateFormatter()
        
        
        dateFormatter2.timeStyle = .full
        dateFormatter2.dateFormat = "EEEE"
        
        let dayString = dateFormatter2.string(from: NSDate() as Date)
        return dateFormatter2.string(from: weatherDate as Date)
        
        
        
    }
    
    
	
	//this is setting the icon from the weather pulled from the dictionary
    
	func weatherIconFromString(stringIcon: String) -> UIImage {
		//setup variable to pull the string from the return
		var imageName: String
		//setup case for the return stuff to pull the image from our folder
		switch stringIcon
		{
		case "clear-day":
			imageName = "clear-day"
		case "clear-night":
			imageName = "clear-night"
		case "rain":
			imageName = "rain"
		case "snow":
			imageName = "snow"
		case "sleet":
			imageName = "sleet"
		case "wind":
			imageName = "wind"
		case "fog":
			imageName = "fog"
		case "cloudy":
			imageName = "cloudy"
		case "partly-cloudy-day":
			imageName = "partly-cloudy"
		case "partly-cloudy-night":
			imageName = "cloudy-night"
		default:
			imageName = "default"
		
		
		
		}
		//set another variable
		
		let iconName = UIImage(named: imageName)
		return iconName!
	}



}
