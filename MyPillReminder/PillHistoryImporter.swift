//
//  PillHistoryImporter.swift
//  MyPillReminder
//
//  Created by Omie C on 14/9/2569 BE.
//

import Foundation

// Clean Codable representation for JSON export
struct PillTakingRecordDTO: Codable {
    var id: UUID
    var scheduleName: String
    var doseLabel: String
    var takenDate: Date
    
    init(from model: PillTaking) {
        self.id = model.id
        self.scheduleName = model.scheduleName
        self.doseLabel = model.doseLabel
        self.takenDate = model.takenDate
    }
}

class PillHistoryExporter {
    static var exportFileURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("pill_history.json")
    }
    
    /// Serializes an array of PillTaking models into a formatted JSON file
    @discardableResult
    static func exportToJSON(records: [PillTaking]) -> String? {
        let dtos = records.map { PillTakingRecordDTO(from: $0) }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(dtos)
            try data.write(to: exportFileURL, options: .atomic)
            
            let jsonString = String(data: data, encoding: .utf8)
            print("📁 History exported successfully to:\n\(exportFileURL.path)")
            return jsonString
        } catch {
            print("❌ Failed to export pill history: \(error.localizedDescription)")
            return nil
        }
    }
}
