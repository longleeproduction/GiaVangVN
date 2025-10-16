
import Foundation
import MediaPlayer

extension MPMediaItem {
    
    public func fileExistsInTemporary() -> URL? {
        let temporaryFolderURL = FileManager.default.temporaryDirectory
        let fileName = "\(self.persistentID).m4a"
        let fileURL = temporaryFolderURL.appendingPathComponent(fileName)
        
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    public func exportToTemporary(with completionHandler: @escaping (_ fileURL: URL?, _ error: Error?) -> ()) {
        if let url = fileExistsInTemporary() {
            completionHandler(url, nil)
        } else {
            if let mediaItemURL = self.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
                let asset = AVURLAsset(url: mediaItemURL)
                let temporaryFolderURL = FileManager.default.temporaryDirectory
                let fileName = "\(self.persistentID).m4a"
                let fileURL = temporaryFolderURL.appendingPathComponent(fileName)
                
                if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
                    exporter.outputURL = fileURL
                    exporter.outputFileType = AVFileType(rawValue: "com.apple.m4a-audio")
                    exporter.exportAsynchronously {
                        DispatchQueue.main.async {
                            if exporter.status == .completed {
                                completionHandler(fileURL, nil)
                            } else {
                                completionHandler(nil, exporter.error)
                            }
                        }
                    }
                } else {
                    completionHandler(nil, nil)
                }
            }
        }
    }
}
