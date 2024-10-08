//
//  BillDetailViewModel.swift
//

import Foundation

class BillDetailViewModel: ObservableObject {
    @Published var bill: Bill?
    @Published var comments: [Comment] = []
    @Published var isLoadingBill = false
    @Published var isLoadingComments = false
    @Published var error: IdentifiableError?
    @Published var showingAddComment = false
    @Published var showingCelebration = false
    @Published var showingFullText = false
    @Published var celebratedVote: Vote?

    private let billId: UUID

    init(billId: UUID) {
        self.billId = billId
    }

    @MainActor
    func fetchBill(dataManager: DataManager) async {
        isLoadingBill = true
        do {
            self.bill = try await dataManager.getBill(for: billId)
        } catch {
            self.error = IdentifiableError(message: "Failed to load bill: \(error.localizedDescription)")
        }
        isLoadingBill = false
    }

    @MainActor
    func fetchComments(dataManager: DataManager) async {
        isLoadingComments = true
        do {
            comments = try await dataManager.getComments(for: billId)
        } catch {
            self.error = IdentifiableError(message: "Failed to load comments: \(error.localizedDescription)")
        }
        isLoadingComments = false
    }

    func vote(_ vote: Vote, voteManager: VoteManager, dataManager: DataManager) async {
        guard let bill = bill else { return }

        do {
            let updatedBill = try await voteManager.castVote(for: bill, vote: vote)
            self.bill = updatedBill
            celebratedVote = vote
            showingCelebration = true
            self.objectWillChange.send()
        } catch {
            if let votingError = error as? VotingError {
                self.error = IdentifiableError(message: votingError.localizedDescription)
            } else {
                self.error = IdentifiableError(message: error.localizedDescription)
            }
        }
    }
}
