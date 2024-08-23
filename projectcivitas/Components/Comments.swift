//
//  Comments.swift

import Foundation
import SwiftUI


struct CommentRow: View {
    let comment: Comment
    let level: Int
    @Binding var bill: Bill
    @State private var isReplying = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.user).font(.headline)
                Spacer()
                Text(comment.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(comment.text)
                .font(.body)
            
            HStack {
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
    }
}

struct CommentsList: View {
    let comments: [Comment]
    @Binding var bill: Bill
    let parentId: UUID?
    let level: Int
    
    var body: some View {
        ForEach(comments) { comment in
            CommentRow(comment: comment, level: level, bill: $bill)
        }
    }
}

struct AddCommentModal: View {
    @Binding var bill: Bill
    @State private var commentText = ""
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
                    submitComment()
                }
                .disabled(commentText.isEmpty)
            }
            .navigationTitle(parentId == nil ? "Add Comment" : "Add Reply")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func submitComment() {
        let newComment = Comment(user: "CurrentUser", text: commentText, timestamp: Date(), parentId: parentId)
        
        if let parentId = parentId {
            addReply(newComment, to: parentId)
        } else {
            bill.comments.append(newComment)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private func addReply(_ reply: Comment, to parentId: UUID) {
        if let index = bill.comments.firstIndex(where: { $0.id == parentId }) {
            bill.comments[index].replies.append(reply)
        } else {
            for i in 0..<bill.comments.count {
                if addReplyRecursively(reply, to: parentId, in: &bill.comments[i]) {
                    break
                }
            }
        }
    }
    
    private func addReplyRecursively(_ reply: Comment, to parentId: UUID, in comment: inout Comment) -> Bool {
        if comment.id == parentId {
            comment.replies.append(reply)
            return true
        }
        
        for i in 0..<comment.replies.count {
            if addReplyRecursively(reply, to: parentId, in: &comment.replies[i]) {
                return true
            }
        }
        
        return false
    }
}
