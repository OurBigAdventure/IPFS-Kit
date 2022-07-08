//
//  SwiftBase58.swift
//  SwiftBase58
//
//  Created by Teo on 19/05/15.
//  Copyright (c) 2015 Teo. All rights reserved.
//
//  Licensed under MIT See LICENCE file in the root of this project for details. 

import Foundation

/// Available alphabets for use in encoding and decoding Base58 strings
public enum Alphabet {
  public static let btc = [UInt8]("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".utf8)
  public static let flickr = [UInt8]("123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ".utf8)
}

/// Encoder / Decoder for base58 String <-> Data conversions
public class Coder58 {
  
  /// Convert base58 bytes to String
  /// - Parameters:
  ///   - bytes: ([UInt8]) bytes to convert
  ///   - alphabet: ([UInt8]) alphabet to use in conversion (defaults to .btc)
  /// - Returns: (String) string representing base58 bytes
  public class func encode(_ bytes: [UInt8],
                           alphabet: [UInt8] = Alphabet.btc) -> String {
    var x = BigUInt(Data(bytes))
    let radix = BigUInt(alphabet.count)
    
    var answer = [UInt8]()
    answer.reserveCapacity(bytes.count)
    
    while x > 0 {
      let (quotient, modulus) = x.quotientAndRemainder(dividingBy: radix)
      answer.append(alphabet[Int(modulus)])
      x = quotient
    }
    
    let prefix = Array(bytes.prefix(while: {$0 == 0})).map { _ in alphabet[0] }
    answer.append(contentsOf: prefix)
    answer.reverse()
    
    return String(bytes: answer, encoding: String.Encoding.utf8) ?? ""
  }
  
  /// Convert base58 string to bytes
  /// - Parameters:
  ///   - string: (String) base58 string to convert
  ///   - alphabet: ([UInt8]) alphabet to use in conversion (defaults to .btc)
  /// - Returns: ([UInt8]) data representing base58 string
  public class func decode(_ string: String,
                           alphabet: [UInt8] = Alphabet.btc) -> [UInt8] {
    var answer = BigUInt(0)
    var j = BigUInt(1)
    let radix = BigUInt(alphabet.count)
    let byteString = [UInt8](string.utf8)
    
    for ch in byteString.reversed() {
      if let index = alphabet.firstIndex(of: ch) {
        answer = answer + (j * BigUInt(index))
        j *= radix
      } else {
        return []
      }
    }
    
    let bytes = answer.serialize()
    
    return Array(bytes)
  }
}
