//
//  MerkleNode.swift
//  SwiftIpfsApi
//
//  Created by Matteo Sartori on 20/10/15.
//
//  Licensed under MIT See LICENCE file in the root of this project for details.

import Foundation

public enum MerkleNodeError : Error {
  case jsonFormatError
  case requiredValueMissing(String)
}

struct MerkleData {
  var hash: String?
  var name: String?
  var size: Int?
  var type: Int?
  var links: [MerkleNode]?
  var data: [UInt8]?
}

public class MerkleNode {
  public let hash: Multihash?
  public let name: String?
  public let size: Int?
  public let type: Int?
  public let links: [MerkleNode]?
  public let data: [UInt8]?
  
  public convenience init(hash: String) throws {
    try self.init(hash: hash, name: nil)
  }
  
  public convenience init(hash: String, name: String?) throws {
    try self.init(hash: hash,
                  name: name,
                  size: nil,
                  type: nil,
                  links: nil,
                  data: nil)
  }
  
  convenience init(data: MerkleData) throws {
    guard data.hash != nil else {
      throw MerkleNodeError.requiredValueMissing("No hash provided!")
    }
    try self.init(hash: data.hash!,
                  name: data.name,
                  size: data.size,
                  type: data.type,
                  links: data.links,
                  data: data.data)
  }
  
  public init(hash: String,
              name: String?,
              size: Int?,
              type: Int?,
              links: [MerkleNode]?,
              data: [UInt8]?) throws {
    self.name = name
    self.size = size
    self.type = type
    self.links = links
    self.data = data
    
    /// hash must be set before exiting with a throw.
    do {
      self.hash = try fromB58String(hash)
    } catch {
      self.hash = nil
      throw error
    }
  }
}

/// Create a Merkle Node from JSON (throws)
/// - Parameter rawJson: (JsonType) raw JSON
/// - Returns: ([MerkleNode?]) array of nodes if they were created
public func merkleNodesFromJson(_ rawJson: JsonType) throws -> [MerkleNode?] {
  var nodes = [MerkleNode?]()
  switch rawJson {
    case .Object(_):
      return [try merkleNodeFromJson2(rawJson)]
    case .Array(let arr):
      for obj in arr {
        nodes.append(try merkleNodeFromJson2(obj))
      }
    default:
      break
  }
  return nodes
}

/// Create a Merkle Node from JSON (throws)
/// - Parameter rawJson: (JsonType) raw JSON
/// - Returns: (MerkleNode) an initialized MerkleNode
public func merkleNodeFromJson2(_ rawJson: JsonType) throws -> MerkleNode {
  guard case .Object(let objs) = rawJson else {
    throw MerkleNodeError.jsonFormatError
  }
  
  guard let hash: String = objs["Hash"]?.string ?? objs["Key"]?.string else {
    throw MerkleNodeError.requiredValueMissing("Neither Hash nor Key exist")
  }

  let name     = objs["Name"]?.string
  let size     = objs["Size"]?.number as? Int
  let type     = objs["Type"]?.number as? Int
  
  var links: [MerkleNode]?
  if let rawLinks = objs["Links"]?.array {
    links    = try rawLinks.map { try merkleNodeFromJson2($0) }
  }
  
  /// Should this be UInt8? The command line output looks like UInt16
  var data: [UInt8]?
  if let strDat = objs["Data"]?.string {
    data = [UInt8](strDat.utf8)
  }
  
  return try MerkleNode(hash: hash,
                        name: name,
                        size: size,
                        type: type,
                        links: links,
                        data: data)
}

/// Create MerkleNode from JSON (throws)
/// - Parameter rawJson: (AnyObject) raw JSON as [String: AnyObject]
/// - Returns: (MerkleNode) an initialized MerkleNode
public func merkleNodeFromJson(_ rawJson: AnyObject) throws -> MerkleNode {

  let objs     = rawJson as! [String: AnyObject]
  
  let hash     = objs["Hash"] == nil ? objs["Key"] as! String : objs["Hash"] as! String
  let name     = objs["Name"] as? String
  let size     = objs["Size"] as? Int
  let type     = objs["Type"] as? Int
  
  var links: [MerkleNode]?
  if let rawLinks = objs["Links"] as? [AnyObject] {
    links    = try rawLinks.map { try merkleNodeFromJson($0) }
  }
  
  /// Should this be UInt8? The command line output looks like UInt16
  var data: [UInt8]?
  if let strDat = objs["Data"] as? String {
    data = [UInt8](strDat.utf8)
  }
  
  return try MerkleNode(hash: hash,
                        name: name,
                        size: size,
                        type: type,
                        links: links,
                        data: data)
}

public func == (lhs: MerkleNode, rhs: MerkleNode) -> Bool {
  return lhs.hash == rhs.hash
}
