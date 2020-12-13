//
//  WeatherManager.swift
//  Clima
//
//  Created by Faiq on 13/12/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(weather: WeatherModel)
}

struct WeatherManager {
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=b6766df6e9826fd7ab23423196c12f38&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString: urlString)
        //print(urlString)
    }
    
    func performRequest(urlString: String) {
        //1. Create a URL
        if let url = URL(string: urlString) {
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            /*
             let task = session.dataTask(
             with: url,
             completionHandler: handle(data:response:error:)
             )*/
            let task = session.dataTask(with: url) {
                (data, response, error) in
                if error != nil {
                    print(error!)
                    //If error occurs, simply exit this func
                    return
                }
                
                if let safeData = data {
                    //un-wrapped data
                    //let dataString = String(data: safeData, encoding: .utf8)
                    if let weather = self.parseJSON(weatherData: safeData) {
                        self.delegate?.didUpdateWeather(weather: weather)
                        //this is a bad pract(have to make WeatherManager reuseable)
                        //let weatherVC = WeatherViewController()
                        //weatherVC.didUpdateWeather(weather)
                    }
                }
            }
            
            //4. Start the task
            task.resume()
        }
    }
    
    //Completion handler part
    /*
     func handle(data: Data?, response: URLResponse?, error: Error?){
     if error != nil {
     print(error)
     //If error occurs, simply exit this func
     return
     }
     
     if let safeData = data {
     let dataString = String(data: safeData, encoding: .utf8)
     print(dataString)
     }
     } */
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            //Instantiating weather struct
            let weather = WeatherModel(
                conditionId: id,
                cityName: name,
                temperature: temp)
            return weather
            //calling func to get type of weather
            //print(weather.conditionName)
            //print(weather.temperatureString)
            
        } catch {
            print(error)
            return nil
        }
    }
    
    
}
