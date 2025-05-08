import SwiftUI
// import Observation // Ensure this is removed or commented out

struct AIChatView: View {
    @ObservedObject var viewModel: AIChatViewModel // Use @ObservedObject

    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            MessageView(message: message)
                                .id(message.id) // For ScrollViewReader
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .onChange(of: viewModel.messages) { oldMessages, newMessages in
                    // Scroll to the bottom when new messages are added
                    if let lastMessage = newMessages.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            HStack {
                TextField("Ask AI...", text: $viewModel.inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...5) // Allow multi-line input up to 5 lines
                    .padding(.leading)
                    .padding(.bottom, 8) // Add some padding at the bottom for the text field
                    .accessibilityLabel("Chat input field")

                Button(action: {
                    Task { // Explicitly wrap in a Task
                        await viewModel.sendMessage()
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.trailing)
                        .padding(.bottom, 8) // Match bottom padding of TextField
                        .accessibilityLabel("Send message")
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.vertical, 10) // Add some vertical padding to the HStack
        }
        .navigationTitle("AI Chat") // Optional: if you have a NavigationView
        // .navigationBarTitleDisplayMode(.inline) // Optional
    }
}

struct MessageView: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer() // Push user messages to the right
                Text(message.text)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityLabel("Your message: \(message.text)")
            } else {
                Text(message.text)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityLabel("AI message: \(message.text)")
                Spacer() // Push AI messages to the left (or keep them left-aligned)
            }
        }
    }
}
