import Foundation

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    // Consider adding a timestamp if you want to display when the message was sent
    // let timestamp: Date = Date()
} 