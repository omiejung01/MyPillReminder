//
//  PillHistoryDocument.swift
//  MyPillReminder
//
//  Created by Omie C on 14/9/2569 BE.
//

import SwiftUI
import UniformTypeIdentifiers

struct PillHistoryDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var jsonText: String
    
    init(jsonText: String = "[]") {
        self.jsonText = jsonText
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents,
           let text = String(data: data, encoding: .utf8) {
            self.jsonText = text
        } else {
            self.jsonText = "[]"
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(jsonText.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
