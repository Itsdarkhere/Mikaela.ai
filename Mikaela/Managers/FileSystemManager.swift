//
//  FileSystemManager.swift
//  LearnLoveApp
//
//  Created by Valtteri Juvonen on 15.4.2024.
//

import Foundation


class FileSystemManager {
    enum FSError: Error {
        case failedToGetDocumentDir
        case failedToGetRecordingsDir
        case failedToCreateRecordingsDir
        case failedToSaveRecording
    }
    
    static var documentDirectory: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    static func getRecordingTempUrl() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let filePath = "tempRecording.caf"
        return tempDir.appendingPathComponent(filePath)
    }
    
    static func getRecordingsDirectoryURL() -> URL? {
        guard let dir = documentDirectory else { return nil }
        return dir.appending(path: "recordings")
    }
    
    static func makeRecordingsDirectory() throws {
        guard let dir = documentDirectory else { throw FSError.failedToGetDocumentDir }
        
        do {
            try FileManager.default.createDirectory(at: dir.appending(path: "recordings"), withIntermediateDirectories: true)
        } catch {
            throw FSError.failedToCreateRecordingsDir
        }
    }
    
    static func isRecordingsDirectoryPresent() -> Bool {
        guard let recordingsDirectoryURL = self.getRecordingsDirectoryURL() else { return false }
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: recordingsDirectoryURL.relativePath, isDirectory:
                                                &isDirectory)
                                                && isDirectory.boolValue
    }
    
    static func saveRecordingFile() -> String? {
        let recordingTempUrl = getRecordingTempUrl()
        let fileName = UUID().uuidString + "." + recordingTempUrl.pathExtension
        
        if (!self.isRecordingsDirectoryPresent()) {
            do {
                try self.makeRecordingsDirectory()
            } catch {
                return nil
            }
        }
        
        guard let recordingsDir = self.getRecordingsDirectoryURL() else { return nil }
        let target = recordingsDir.appending(path: fileName)
        
        
        do {
            try FileManager.default.moveItem(at: recordingTempUrl, to: target)
        } catch {
            return nil
        }
        
        return fileName
    }
    
    static func getRecordingURL(_ fileName: String) -> URL? {
        guard let dir = getRecordingsDirectoryURL() else { return nil }
        return dir.appendingPathComponent(fileName)
    }
}
