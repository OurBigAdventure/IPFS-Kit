//
//  NetworkIo.swift
//  SwiftIpfsApi
//
//  Created by Matteo Sartori on 21/10/15.
//
//  Copyright © 2015 Teo Sartori. All rights reserved.
//
//  Licensed under MIT See LICENCE file in the root of this project for details. 

import Foundation

public protocol NetworkIo {
  
  /// Make a call to an API endpoint
  /// - Parameters:
  ///   - source: (String) api endpoint to call
  ///   - completionHandler: (Data)->() to allow you to process the returned data
  func receiveFrom(_ source: String, completionHandler: @escaping (Data) throws -> Void) throws
  
  /// Stream Data from and API endpoint
  /// - Parameters:
  ///   - source: (String) api endpoint to stream from
  ///   - updateHandler: (Data, URLSessionDataTask)->Bool to allow you to handle incoming data
  ///   - completionHandler: (AnyObject)->() to allow you to handle the completion of the stream
  func streamFrom(_ source: String, updateHandler: @escaping (Data, URLSessionDataTask) throws -> Bool, completionHandler: @escaping (AnyObject) throws -> Void) throws
  
  /// Send a Data object to an API endpoint
  /// - Parameters:
  ///   - target: (String) api endpoint to send to
  ///   - content: (Data) data object to send
  ///   - completionHandler: (Data)->() to allow you to handle the returned data from the call
  func sendTo(_ target: String, content: Data, completionHandler: @escaping (Data) -> Void) throws
  
  /// Send the contents of a file to an API endpoint
  /// - Parameters:
  ///   - target: (String) api endpoint to send to
  ///   - filePath: (String) path to file to send
  ///   - completionHandler: (Data)->() to allow you to handle the returned data from the call
  func sendTo(_ target: String, filePath: String, completionHandler: @escaping (Data) -> Void) throws
}
