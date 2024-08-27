import Foundation
import SwiftUI

struct Comment: Identifiable {
    let id = UUID()
    let user: String
    let text: String
    let timestamp: Date
    let parentId: UUID?
    var replies: [Comment]
    var upvotes: Int
    var userHasUpvoted: Bool

    var totalReplyCount: Int {
        replies.reduce(0) { $0 + $1.totalReplyCount + 1 }
    }
}

struct CommentRow: View {
    let comment: Comment
    let level: Int
    let billId: UUID
    let updateComment: (Comment) -> Void
    @EnvironmentObject var dataManager: DataManager
    @State private var isReplying = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.user).font(.subheadline).bold()
                Spacer()
                Text(comment.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(comment.text)
                .font(.body)

            HStack {
                Button(action: {
                    Task {
                        await upvoteComment()
                    }
                }) {
                    Image(systemName: comment.userHasUpvoted ? "hand.thumbsup.fill" : "hand.thumbsup")
                    Text("\(comment.upvotes)")
                }
                .foregroundColor(comment.userHasUpvoted ? .blue : .gray)

                Button("Reply") {
                    isReplying = true
                }
                .font(.caption)
                .foregroundColor(.blue)
                Spacer()
            }

            if !comment.replies.isEmpty {
                CommentsList(comments: comment.replies, billId: billId, parentId: comment.id, level: level + 1)
            }
        }
        .padding(.leading, CGFloat(level) * 20)
        .padding(.vertical, 8)
        .sheet(isPresented: $isReplying) {
            AddCommentModal(billId: billId, parentId: comment.id, onCommentAdded: {
                Task {
                    await fetchUpdatedComments()
                }
            })
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func upvoteComment() async {
        do {
            var updatedComment = comment
            if !updatedComment.userHasUpvoted {
                updatedComment.upvotes += 1
                updatedComment.userHasUpvoted = true
            } else {
                updatedComment.upvotes -= 1
                updatedComment.userHasUpvoted = false
            }
            // Here you would typically call an API to update the upvote status
            // For now, we'll just simulate it with a delay
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            updateComment(updatedComment)
        } catch {
            await MainActor.run {
                errorMessage = "Failed to update upvote. Please try again."
                showError = true
            }
        }
    }

    private func fetchUpdatedComments() async {
        do {
            let updatedComments = try await dataManager.fetchComments(for: billId)
            if let updatedComment = findComment(id: comment.id, in: updatedComments) {
                updateComment(updatedComment)
            }
        } catch {
            errorMessage = "Failed to fetch updated comments: \(error.localizedDescription)"
            showError = true
        }
    }

    private func findComment(id: UUID, in comments: [Comment]) -> Comment? {
        for comment in comments {
            if comment.id == id {
                return comment
            }
            if let found = findComment(id: id, in: comment.replies) {
                return found
            }
        }
        return nil
    }
}

struct CommentsList: View {
    let comments: [Comment]
    let billId: UUID
    let parentId: UUID?
    let level: Int
    @State private var sortOption: CommentSortOption = .newest
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        VStack {
            if level == 0 {
                Picker("Sort", selection: $sortOption) {
                    ForEach(CommentSortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
            }

            ForEach(sortedComments) { comment in
                CommentRow(comment: comment, level: level, billId: billId) { updatedComment in
                    updateComment(updatedComment)
                }
            }
        }
    }

    private var sortedComments: [Comment] {
        comments.sorted { first, second in
            switch sortOption {
            case .newest:
                return first.timestamp > second.timestamp
            case .oldest:
                return first.timestamp < second.timestamp
            case .mostUpvotes:
                return first.upvotes > second.upvotes
            }
        }
    }

    private func updateComment(_ updatedComment: Comment) {
        Task {
            do {
                // Here you would typically call an API to update the comment
                // For now, we'll just simulate it with a delay
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                let updatedComments = try await dataManager.fetchComments(for: billId)
                await MainActor.run {
                    // Update the UI with the fetched comments
                    // This might require restructuring how we store and update comments
                }
            } catch {
                print("Failed to update comment: \(error.localizedDescription)")
            }
        }
    }
}

enum CommentSortOption: String, CaseIterable {
    case newest = "Newest"
    case oldest = "Oldest"
    case mostUpvotes = "Most Upvotes"
}

struct AddCommentModal: View {
    let billId: UUID
    @State private var commentText = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    let parentId: UUID?
    let onCommentAdded: () async -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Comment")) {
                    TextEditor(text: $commentText)
                        .frame(height: 100)
                }

                Button("Submit Comment") {
                    Task {
                        await submitComment()
                    }
                }
                .disabled(commentText.isEmpty)
            }
            .navigationTitle(parentId == nil ? "Add Comment" : "Add Reply")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func submitComment() async {
        guard !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Comment cannot be empty."
            showError = true
            return
        }

        do {
            let newComment = Comment(user: "CurrentUser", text: commentText, timestamp: Date(), parentId: parentId, replies: [], upvotes: 0, userHasUpvoted: false)

            try await dataManager.addComment(to: billId, comment: newComment)

            await onCommentAdded()

            await MainActor.run {
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to submit comment: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}
