import Foundation
import Combine // For ObservableObject and @Published

@MainActor
final class AIChatViewModel: ObservableObject { // Conform to ObservableObject
    @Published var messages: [ChatMessage] = [] // Mark with @Published
    @Published var inputText: String = ""      // Mark with @Published
    
    // IMPORTANT: You have your OpenAI API key here. Be mindful of version control.
    private let openAIAPIKey = "..."
    private let openAIURL = URL(string: "https://api.openai.com/v1/chat/completions")!

    // Make sendMessage async
    func sendMessage() async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        let userMessage = ChatMessage(text: inputText, isFromUser: true)
        messages.append(userMessage)
        let messageToSend = inputText
        inputText = "" // Clear input after sending

        await fetchOpenAIResponse(for: messageToSend)
    }

    // Make fetchOpenAIResponse async and use await for the network call
    private func fetchOpenAIResponse(for prompt: String) async {
        let thinkingMessage = ChatMessage(text: "AI is thinking...", isFromUser: false)
        messages.append(thinkingMessage)
        
        var request = URLRequest(url: openAIURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": prompt]]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Error serializing request body: \(error)")
            removeThinkingMessageAndAddError(errorMessage: "Error preparing message for AI.")
            return
        }
        
        do {
            // Use async URLSession API
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check HTTP response status, though data(for:) throws for bad network/server errors
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("OpenAI API request failed with status code: \(statusCode)")
                // Try to decode error from OpenAI if possible
                var errorMessage = "AI request failed (status: \(statusCode))."
                if let errorDetails = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                    errorMessage += " Details: \(errorDetails.error.message)"
                }
                removeThinkingMessageAndAddError(errorMessage: errorMessage)
                return
            }

            // Remove thinking message before processing successful response or parsing error
            messages.removeAll { $0.text == "AI is thinking..." && !$0.isFromUser }

            if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = jsonResponse["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let assistantMessageText = message["content"] as? String {
                messages.append(ChatMessage(text: assistantMessageText.trimmingCharacters(in: .whitespacesAndNewlines), isFromUser: false))
            } else {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Failed to parse OpenAI response. Raw response: \(responseString)")
                }
                messages.append(ChatMessage(text: "Sorry, I couldn't understand the AI's response.", isFromUser: false))
            }
        } catch {
            print("Error fetching or parsing OpenAI response: \(error.localizedDescription)")
            // Ensure thinking message is removed on any error during the try block
            messages.removeAll { $0.text == "AI is thinking..." && !$0.isFromUser }
            messages.append(ChatMessage(text: "Sorry, an error occurred: \(error.localizedDescription)", isFromUser: false))
        }
    }
    
    // This helper is also now @MainActor implicitly
    private func removeThinkingMessageAndAddError(errorMessage: String) {
        messages.removeAll { $0.text == "AI is thinking..." && !$0.isFromUser }
        messages.append(ChatMessage(text: errorMessage, isFromUser: false))
    }
}

// Helper struct for decoding OpenAI API error responses
struct OpenAIErrorResponse: Decodable {
    struct ErrorDetail: Decodable {
        let message: String
        let type: String?
        // let param: String? // Sometimes present
        // let code: String?  // Sometimes present
    }
    let error: ErrorDetail
} 
