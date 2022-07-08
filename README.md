# IPFSKit

Based on: https://github.com/ipfs-shipyard/swift-ipfs-http-client
Converted into a standalone Swift Package here. https://github.com/pexavc/IPFSKit
Commented and unused code removed, documentation ongoing, singleton interface added.

## Installation

Use SPM

## Usage

```swift
import IPFSKit

// writing
let videoCID = await IPFS.shared.store(data: fileData)
let jsonCID = await IPFS.shared.store(string: jsonString)

// reading
let videoData = await IPFS.shared.getData(cid: videoCID)
let jsonString = await IPFS.shared.getString(cid: jsonCID)

// pinning
let pins = IPFS.shared.pin(cid: videoCID)

// unpinning
IPFS.shared.unpin(cid: jsonCID)

```
