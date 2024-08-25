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
    @Binding var bill: Bill
    let updateComment: (Comment) -> Void
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
                CommentsList(comments: comment.replies, bill: $bill, parentId: comment.id, level: level + 1)
            }
        }
        .padding(.leading, CGFloat(level) * 20)
        .padding(.vertical, 8)
        .sheet(isPresented: $isReplying) {
            AddCommentModal(bill: $bill, parentId: comment.id)
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
}

struct CommentsList: View {
    let comments: [Comment]
    @Binding var bill: Bill
    let parentId: UUID?
    let level: Int
    @State private var sortOption: CommentSortOption = .newest
    
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
                CommentRow(comment: comment, level: level, bill: $bill) { updatedComment in
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
        if let index = bill.comments.firstIndex(where: { $0.id == updatedComment.id }) {
            bill.comments[index] = updatedComment
        } else {
            updateNestedComment(updatedComment, in: &bill.comments)
        }
    }
    
    private func updateNestedComment(_ updatedComment: Comment, in comments: inout [Comment]) {
        for i in 0..<comments.count {
            if comments[i].id == updatedComment.id {
                comments[i] = updatedComment
                return
            }
            updateNestedComment(updatedComment, in: &comments[i].replies)
        }
    }
}

enum CommentSortOption: String, CaseIterable {
    case newest = "Newest"
    case oldest = "Oldest"
    case mostUpvotes = "Most Upvotes"
}

struct AddCommentModal: View {
    @Binding var bill: Bill
    @State private var commentText = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.presentationMode) var presentationMode
    let parentId: UUID?
    
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
            await MainActor.run {
                errorMessage = "Comment cannot be empty."
                showError = true
            }
            return
        }
        
        do {
            let newComment = Comment(user: "CurrentUser", text: commentText, timestamp: Date(), parentId: parentId, replies: [], upvotes: 0, userHasUpvoted: false)
            
            if let parentId = parentId {
                try await addReply(newComment, to: parentId)
            } else {
                await MainActor.run {
                    bill.comments.append(newComment)
                }
            }
            
            // Here you would typically call an API to save the comment
            // For now, we'll just simulate it with a delay
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            await MainActor.run {
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to submit comment. Please try again."
                showError = true
            }
        }
    }
    
    private func addReply(_ reply: Comment, to parentId: UUID) async throws {
        if let index = bill.comments.firstIndex(where: { $0.id == parentId }) {
            await MainActor.run {
                bill.comments[index].replies.append(reply)
            }
        } else {
            for i in 0..<bill.comments.count {
                if try await addReplyRecursively(reply, to: parentId, in: &bill.comments[i]) {
                    return
                }
            }
            throw CommentError.parentCommentNotFound
        }
    }
    
    private func addReplyRecursively(_ reply: Comment, to parentId: UUID, in comment: inout Comment) async throws -> Bool {
        if comment.id == parentId {
            comment.replies.append(reply)
            return true
        }
        
        for i in 0..<comment.replies.count {
            if try await addReplyRecursively(reply, to: parentId, in: &comment.replies[i]) {
                return true
            }
        }
        
        return false
    }
}

enum CommentError: Error {
    case parentCommentNotFound
}
