//
//  RecordRepository.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/7/24.
//

import Firebase
import FirebaseFirestore

final class RecordRepository: DefaultRecordRepository {
	private let db = Firestore.firestore()
	private let collectionPath = "record"
}

extension RecordRepository {
	func createRecord(data: [String : Any]) async throws {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		if let recordSelectDate = data["calendar_date"] {
			let recordSelectDateString = String(describing: recordSelectDate)
			let documentRef = db.collection("user")
				.document(userID).collection("record").document(recordSelectDateString)
			try await withCheckedThrowingContinuation {
				(continuation: CheckedContinuation<Void, Error>) in
				documentRef.setData(data) { error in
					if let error = error {
						continuation.resume(throwing: error)
					} else {
						continuation.resume()
					}
				}
			}
		}
	}
	
	// TODO: read, update, delete
}
