//
//  Multipart.swift
//  SwiftIpfsApi
//
//  Created by Matteo Sartori on 20/10/15.
//  Copyright © 2015 Teo Sartori. All rights reserved.
//
//  Licensed under MIT See LICENCE file in the root of this project for details. 

import Foundation

/// Multi-part form data error
public enum MultipartError : Error {
  case failedURLCreation
  case invalidEncoding
}

/// Multi-part form data encoder for data transfer via TCP
public struct Multipart {
  
  static let lineFeed:String = "\r\n"
  let boundary: String
  let encoding: String.Encoding
  let charset: String
  var body = NSMutableData()
  let request: NSMutableURLRequest
  
  init(targetUrl: String, encoding: String.Encoding) throws {
    
    // Eg. UTF8
    self.encoding = encoding
    guard let charset = Multipart.charsetString(from: encoding) else { throw MultipartError.invalidEncoding }
    
    self.charset = charset
    
    boundary = Multipart.createBoundary()
    
    guard let url = URL(string: targetUrl) else { throw MultipartError.failedURLCreation }
    request = NSMutableURLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary="+boundary, forHTTPHeaderField: "content-type")
    request.setValue("Swift IPFS Client", forHTTPHeaderField: "user-agent")
  }
}

extension Multipart {
  
  /// Character set to use for Multi-Part form data
  /// - Parameter encoding: (String.Encoding) encoding requested
  /// - Returns: (String?) representation of string encoding for use in Multi-Part form encoding
  static func charsetString(from encoding: String.Encoding) -> String? {
    switch encoding {
      case .utf8:
        return "UTF8"
      case .ascii:
        return "ASCII"
      default:
        return nil
    }
  }
  
  /// Generate a string of 32 random alphanumeric characters.
  static func createBoundary() -> String {
    
    let allowed     = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let maxCount    = allowed.count
    let count       = 32
    var output      = ""
    
    for _ in 0 ..< count {
      let r = Int(arc4random_uniform(UInt32(maxCount)))
      let randomIndex = allowed.index(allowed.startIndex, offsetBy: r)
      
      output += String(allowed[randomIndex])
    }
    
    return output
  }

  /// Add a form field to the Multi-part form data
  /// - Parameters:
  ///   - oldMultipart: (Multipart) original Multipart
  ///   - name: (String) field name
  ///   - value: (String) field value
  /// - Returns: (Multipart) updated Multipart
  static func addFormField(oldMultipart: Multipart, name: String, value: String) throws -> Multipart {
    
    let encoding = oldMultipart.encoding
    
    var outString = "--" + oldMultipart.boundary + lineFeed
    oldMultipart.body.append(outString.data(using: encoding)!)
    
    outString = "content-disposition: form-data; name=\"" + name + "\"" + lineFeed
    oldMultipart.body.append(outString.data(using: encoding)!)
    
    outString = "content-type: text/plain; charset=\"" + oldMultipart.charset + "\"" + lineFeed
    oldMultipart.body.append(outString.data(using: encoding)!)
    
    oldMultipart.body.append(lineFeed.data(using: encoding)!)
    
    oldMultipart.body.append(value.data(using: encoding)!)
    oldMultipart.body.append(lineFeed.data(using: encoding)!)
    
    return oldMultipart
  }

  /// Add a file directory to the Multi-part form data
  /// - Parameters:
  ///   - oldMultipart: (Multipart) original Multipart
  ///   - path: (String) path to directory
  /// - Returns: (Multipart) updated Multipart
  static func addDirectoryPart(oldMultipart: Multipart, path: String) throws -> Multipart {
    
    let encoding = oldMultipart.encoding
    
    var outString = "--" + oldMultipart.boundary + lineFeed
    oldMultipart.body.append(outString.data(using: encoding)!)
    
    outString = "content-disposition: file; filename=\"\(path)\"" + lineFeed
    oldMultipart.body.append(outString.data(using: encoding)!)
    
    outString = "content-type: application/x-directory" + lineFeed
    oldMultipart.body.append(outString.data(using: encoding)!)
    
    outString = "content-transfer-encoding: binary" + lineFeed
    oldMultipart.body.append(outString.data(using: encoding)!)
    
    oldMultipart.body.append(lineFeed.data(using: encoding)!)
    oldMultipart.body.append(lineFeed.data(using: encoding)!)
    
    return oldMultipart
  }

  /// Add a file to the Multi-part form data
  /// - Parameters:
  ///   - oldMultipart: (Multipart) original Multipart
  ///   - fileName: (String?) file name
  ///   - fileData: (Data) file data
  /// - Returns: (Multipart) updated Multipart
  public static func addFilePart(_ oldMultipart: Multipart, fileName: String?, fileData: Data) throws -> Multipart {
    
    var outString = "--" + oldMultipart.boundary + lineFeed
    oldMultipart.body.append(outString.data(using: String.Encoding.utf8)!)
    
    if fileName != nil {
      outString = "content-disposition: file; filename=\"\(fileName!)\";" + lineFeed
    } else {
      outString = "content-disposition: file; name=\"file\";" + lineFeed
    }
    
    oldMultipart.body.append(outString.data(using: String.Encoding.utf8)!)
    
    outString = "content-type: application/octet-stream" + lineFeed
    oldMultipart.body.append(outString.data(using: String.Encoding.utf8)!)
    
    outString = "content-transfer-encoding: binary" + lineFeed + lineFeed
    oldMultipart.body.append(outString.data(using: String.Encoding.utf8)!)
    
    /// Add the actual data for this file.
    oldMultipart.body.append(fileData)
    oldMultipart.body.append(lineFeed.data(using: String.Encoding.utf8)!)
    
    return oldMultipart
  }

  /// Complete the Multi-part form data
  /// - Parameters:
  ///   - multipart: (Multipart) Multipart to complete
  ///   - completionHandler: (Data)->Void to allow you to handle the returned data
  public static func finishMultipart(_ multipart: Multipart, completionHandler: @escaping (Data) -> Void) {
    
    let outString = "--" + multipart.boundary + "--" + lineFeed
    
    multipart.body.append(outString.data(using: String.Encoding.utf8)!)
    
    multipart.request.setValue(String(multipart.body.length), forHTTPHeaderField: "content-length")
    multipart.request.httpBody = multipart.body as Data
    
    /// Send off the request
    let task = URLSession.shared.dataTask(with: (multipart.request as URLRequest)) {
      (data: Data?, response: URLResponse?, error: Error?) -> Void in
      
      // FIXME: use Swift 5 Result type rather than passing nil data.
      if error != nil || data == nil {
        print("Error in dataTaskWithRequest: \(String(describing: error))")
        let emptyData = Data()
        completionHandler(emptyData)
        return
      }
      
      completionHandler(data!)
      
    }
    
    task.resume()
  }
}
