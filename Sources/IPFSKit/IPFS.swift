//
//  IPFS.swift
//
//  Created by Chris Brown on 2/3/22.
//

import Foundation

class IPFS {
  static let shared = IPFS()
  private var ipfsClient: IPFSClient?

  private init() {
    do {
      ipfsClient = try IPFSClient.init(host: "ipfs.infura.io",
                                       port: 5001,
                                       ssl: true)
    } catch let error {
      print("🧨🌎 Could not initialize IPFS Client: \(error.localizedDescription)")
      ipfsClient = nil
    }
  }

  /// Store a string to IPFS
  /// - Parameter string: (String) string to store
  /// - Returns: (String?) CID for stored string or nil
  func store(string: String) async -> String? {
    await withUnsafeContinuation { c in
      do {
        try ipfsClient?.add(string) { nodes in // Adding data to IPFS
                                               // use 'nodes' to pin content
          if let node = nodes.first,
             let hash = node.hash {
            c.resume(returning: b58String(hash))
          }
        }
      } catch let error {
        print("🧨🌎 IPFS error saving data:\n\(error.localizedDescription)")
        c.resume(returning: nil)
      }
    }
  }

  /// Store data to IPFS
  /// - Parameter data: (Data) to be stored
  /// - Returns: (String?) CID for stored data or nil
  func store(data: Data) async -> String? {
    await withUnsafeContinuation { c in
      do {
        try ipfsClient?.add(data) { nodes in // Adding data to IPFS
                                             // use 'nodes' to pin content
          if let node = nodes.first,
             let hash = node.hash {
            try? self.ipfsClient?.name.publish(ipfsPath: "/ipfs/\(b58String(hash))") { result in
              print(result)
            }
            c.resume(returning: b58String(hash))
            return
          }
        }
      } catch let error {
        print("🧨🌎 IPFS error saving data:\n\(error.localizedDescription)")
        c.resume(returning: nil)
      }
    }
  }

  /// Get data value of item stored in IPFS
  /// - Parameter cid: (String) cid of item
  /// - Returns: (Data?) contents of item or nil
  func getData(cid: String) async -> Data? {
    await withUnsafeContinuation { c in
      do {
        try ipfsClient?.get(fromB58String(cid)) { returnData in
          c.resume(returning:Data(returnData))
        }
      } catch let error {
        print("🧨🌎 IPFS error retrieving data:\n\(error.localizedDescription)")
        c.resume(returning: nil)
      }
    }
  }

  /// Get string value of item stored in IPFS
  /// - Parameter cid: (String) cid of item
  /// - Returns: (String?) contents of item or nil
  func getString(cid: String) async -> String? {
    await withUnsafeContinuation { c in
      do {
        try ipfsClient?.get(fromB58String(cid)) { returnData in
          let data = Data(returnData)
          let string = String(data: data, encoding: .utf8)
          c.resume(returning: string)
        }
      } catch let error {
        print("🧨🌎 IPFS error retrieving data:\n\(error.localizedDescription)")
        c.resume(returning: nil)
      }
    }
  }

  /// Pin an item in IPFS
  /// - Parameter cid: (String) cid of item in IPFS
  /// - Returns: ([String]) array of pin hash values returned by IPFS
  @discardableResult
  func pin(cid: String) async -> [String] {
    await withUnsafeContinuation { c in
      var pinnedHashes = [String]()
      do {
        try ipfsClient?.pin.add(fromB58String(cid)) { pinHashArray in
          for pinHash in pinHashArray {
            pinnedHashes.append(b58String(pinHash))
          }
          c.resume(returning: pinnedHashes)
        }
      } catch let error {
        print("🧨🌎 IPFS error pinning hash:\n\(error.localizedDescription)")
        c.resume(returning: pinnedHashes)
      }
    }
  }

  /// UnPin a hash from IPFS
  /// - Parameter cid: (String) CID of item in IPFS
  func unpin(cid: String) {
    do {
      try ipfsClient?.pin.rm(fromB58String(cid), completionHandler: { _ in
        print("📌 pin removed")
      })
    } catch let error {
      print("🧨 Could not remove Pins: \(error.localizedDescription)")
    }
  }

}
