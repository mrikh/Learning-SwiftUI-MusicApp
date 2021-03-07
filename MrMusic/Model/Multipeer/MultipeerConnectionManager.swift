//
//  MultipeerConnectionManager.swift
//  MrMusic
//
//  Created by Mayank Rikh on 06/03/21.
//

import MultipeerConnectivity
import MediaPlayer
import SwiftUI

class MultipeerConnectionManager: NSObject, ObservableObject{
    
    @Published var showAlert = false
    var alertString : String?
    
    @Published var peers: [MCPeerID] = []
    private var nearbyServiceBrowser: MCNearbyServiceBrowser
    
    typealias MusicReceivedHandler = (MPMediaItem) -> ()
    private static let service = "mrmusic"
    private let myPeerId = MCPeerID(displayName : UIDevice.current.name)
    
    private let session : MCSession
    var musicReceiveHandler : MusicReceivedHandler?
    private var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    private var invitationHandler: ((Bool, MCSession?) -> ())?
    
    var musicItemToSend : MPMediaItem?
    
    init(_ musicReceiveHandler : MusicReceivedHandler? = nil){
        
        //just to trigger pop up for local network
        let _ = ProcessInfo.processInfo.hostName
        
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .none)
        self.musicReceiveHandler = musicReceiveHandler
        
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: MultipeerConnectionManager.service)
        
        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: MultipeerConnectionManager.service)
        
        super.init()
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceBrowser.delegate = self
        session.delegate = self
    }
    
    func invitation(accept : Bool){
        self.invitationHandler?(accept, accept ? self.session : nil)
    }
    
    func advertisingUpdate(start : Bool){
        if start{
            nearbyServiceAdvertiser.startAdvertisingPeer()
        }else{
            nearbyServiceAdvertiser.stopAdvertisingPeer()
        }
    }
    
    func browsingUpdate(start : Bool){
        start ? nearbyServiceBrowser.startBrowsingForPeers() : nearbyServiceBrowser.stopBrowsingForPeers()
    }
    
    func invitePeer(_ peerId : MCPeerID){
        
        let context = (musicItemToSend?.title ?? "Random song").data(using: .utf8)
        nearbyServiceBrowser.invitePeer(peerId, to: session, withContext: context, timeout: TimeInterval(600))
    }
    
    private func sendTo(_ peer: MCPeerID) {
        getData { (data) in
            try! self.session.send(data, toPeers: [peer], with: .reliable)
        }
    }
    
    private func getData(_ completion : @escaping (Data)->()){
        
        guard let item = self.musicItemToSend, let url = item.assetURL else {return}
        export(url) { (outputUrl, error) in
            let data = try! Data(contentsOf: outputUrl!)
            completion(data)
        }
    }
    
    private func export(_ assetURL: URL, completionHandler: @escaping (_ fileURL: URL?, _ error: Error?) -> ()) {
        let asset = AVURLAsset(url: assetURL)
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            completionHandler(nil, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Sorry! Something went wrong."]))
            return
        }
        
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(NSUUID().uuidString)
            .appendingPathExtension("m4a")
        
        exporter.outputURL = fileURL
        exporter.outputFileType = .m4a
        
        exporter.exportAsynchronously {
            if exporter.status == .completed {
                completionHandler(fileURL, nil)
            } else {
                completionHandler(nil, exporter.error)
            }
        }
    }
}

extension MultipeerConnectionManager : MCNearbyServiceAdvertiserDelegate{
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        //context can be any type of data
        guard let context = context, let jobName = String(data: context, encoding: .utf8) else { return }
        
        alertString = "Would you like to accept: \(jobName) from \(peerID.displayName)"
        self.invitationHandler = invitationHandler
        showAlert = true
    }
}

extension MultipeerConnectionManager : MCNearbyServiceBrowserDelegate{
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        if !peers.contains(peerID){
            peers.append(peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
        guard let index = peers.firstIndex(of: peerID) else {return}
        peers.remove(at: index)
    }
}

extension MultipeerConnectionManager : MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        switch state {
        case .connected:
            sendTo(peerID)
        default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        let tempFile = TemporaryMediaFile(withData: data)
        let media = TempMediaItem(id: 1345345345341, assetUrl : tempFile.url)
        musicReceiveHandler?(media)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}
