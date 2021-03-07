//
//  TemporaryMediaFile.swift
//  MrMusic
//
//  Created by Mayank Rikh on 06/03/21.
//

import AVKit

class TemporaryMediaFile {
    var url: URL?

    init(withData: Data) {
        deleteFile()
        let directory = FileManager.default.temporaryDirectory
        let fileName = "\(NSUUID().uuidString).m4a"
        let url = directory.appendingPathComponent(fileName)
        do {
            try withData.write(to: url)
            self.url = url
        } catch {
            print("Error creating temporary file: \(error)")
        }
    }

    public var avAsset: AVAsset? {
        if let url = self.url {
            return AVAsset(url: url)
        }

        return nil
    }

    public func deleteFile() {
        if let url = self.url {
            do {
                try FileManager.default.removeItem(at: url)
                self.url = nil
            } catch {
                print("Error deleting temporary file: \(error)")
            }
        }
    }
}
