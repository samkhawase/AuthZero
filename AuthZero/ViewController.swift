//
//  ViewController.swift
//  AuthZero
//
//  Created by Sam Khawase on 21.02.20.
//  Copyright © 2020 B3rlin. All rights reserved.
//

import UIKit
import Auth0
import JWTDecode

class ViewController: UIViewController {

    //Enter your Audience String which should be in format
    //https://<YOUR_DOMAIN>.eu.auth0.com/userinfo
    let audienceString = ""
    
    @IBOutlet weak var httpStatus: UILabel!
    @IBOutlet weak var amenityTitle: UITextField!
    @IBOutlet weak var amenityList: UILabel!
    @IBOutlet weak var postAmenityButton: UIButton!
    @IBOutlet weak var getAmenityButton: UIButton!
    
    var token = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAmenityButton.isEnabled = false
        postAmenityButton.isEnabled = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    @IBAction func performLogin(_ sender: Any) {
        Auth0
            .webAuth()
            .scope("openid profile")
            .audience("https://redonion.eu.auth0.com/userinfo")
            .start { [weak self] in
                switch $0 {
                case .failure(let error):
                    // Handle the error
                    print("Error: \(error)")
                case .success(let credentials):
                    // Do something with credentials e.g.: save them.
                    // Auth0 will automatically dismiss the login page
                    if let jwt = credentials.idToken {
                        print("Credentials: \(jwt)")
                        self?.token = jwt
                        DispatchQueue.main.async {
                            self?.httpStatus.text = "Logged in Successfuly"
                            self?.getAmenityButton.isEnabled = true
                            self?.postAmenityButton.isEnabled = true
                        }
                    }
                }
        }
        
    }
    
    @IBAction func postAmenity(_ sender: Any) {
        postAmenity(token: token)
    }
    
    @IBAction func getAmenities(_ sender: Any) {
        getStatus(token)
    }
    
    func checkRole(token: String) {
        guard let jwt = try? decode(jwt: token),
            let _ = jwt.claim(name: "https://postgrest-demo.de/role").array
            else {
                print("role not found")
                return
        }
        print("role found in JWT")
        
    }
    
    func getStatus(_ token: String)  {
        guard let url = URL(string: "http://localhost:3000/amenity")
            else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let jwt = "Bearer \(token)"
        request.setValue(jwt, forHTTPHeaderField: "Authorisation")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: request) { (data, response, error) in
            let decoder = JSONDecoder()
            if let data = data,
               let serverResponse = try? decoder.decode([Amenity].self, from: data),
               let response = response as? HTTPURLResponse,
               200...299 ~= response.statusCode {
                DispatchQueue.main.async {
                    _ = serverResponse.map { (amenity) -> Void in
                        self.amenityList.text?.append("id: \(amenity.amenity_id)\t")
                        self.amenityList.text?.append("name: \(amenity.amenity_name)")
                        self.amenityList.text?.append("\n")
                    }
                }
            }
        }.resume()
    }
    func postAmenity(token: String) {
        guard let url = URL(string: "http://localhost:3000/amenity"),
              let amenity_name = amenityTitle.text
            else { return }
        
        let jwt = "Bearer \(token)"
        
        //if let amenity_name = amenityTitle.text //"swifty_amenity"
        let newAmenity = """
                {
                    "amenity_name": "\(amenity_name)",
                    "amenity_address": "swifty_address"
                }
        """.data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = newAmenity
        request.setValue(jwt, forHTTPHeaderField: "Authorization")
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Content-Range")
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        alertController.addAction(cancelAction)

        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        alertController.addAction(OKAction)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
               201 == response.statusCode {
                DispatchQueue.main.async {
                    self.amenityTitle.text = ""
                    alertController.title = "Success"
                    alertController.message = "Status Code: \(response.statusCode)"
                    self.present(alertController, animated: true) {}
                }
            } else {
                DispatchQueue.main.async {
                    if let response = response as? HTTPURLResponse {
                        alertController.title = "Error"
                        alertController.message = "Status Code: \(response.statusCode)"
                        self.present(alertController, animated: true) {}
                    }
                }
            }
        }.resume()
    }
}

struct Amenity: Codable {
    var amenity_id: Int
    var amenity_name: String
    var amenity_address: String
    var created_on: String
}
