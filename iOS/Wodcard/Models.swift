import Foundation

struct LogEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var value1: Double
    var value2: Double
    var notes: String

    static let value1Label = "Time"
    static let value1Unit = "sec"
    static let value2Label = "Rounds/reps"
    static let value2Unit = "reps"
    static let notesLabel = "Workout notes"
    static let entryNoun = "WOD"
}
