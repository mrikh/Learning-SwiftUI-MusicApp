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

