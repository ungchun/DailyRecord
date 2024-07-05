//
//  FirebaseDemo.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/23/24.
//

import Firebase
import FirebaseFirestore

enum CollectionPath: String {
	case user
}

final class FirestoreService {
	static let shared = FirestoreService()
	private let db = Firestore.firestore()
	
	private init() {}
}

extension FirestoreService {
	
	// MARK: - Create
	
	func create(
		collectionPath: CollectionPath,
		data: [String : Any]
	) async throws {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		let documentRef = db.collection(collectionPath.rawValue)
		try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
			let docID = documentRef.document().documentID
			documentRef.document(collectionPath == .user
													 ? userID : docID).setData(data) { [weak self] error in
				if let error = error {
					continuation.resume(throwing: error)
				} else {
					if collectionPath == .user { // 회원가입
						Task { [weak self] in
							guard let self = self else { return }
							do {
								try await self.update(collectionPath: .user,
																			docID: userID,
																			updateData: ["uid": userID])
								UserDefaultsSetting.uid = userID
								continuation.resume()
							} catch {
								continuation.resume(throwing: error)
							}
						}
					} else {
						continuation.resume()
					}
				}
			}
		}
	}
	
	// MARK: - Read
	
	func read(
		collectionPath: CollectionPath,
		docID: String
	) async throws -> [String: Any]? {
		let documentRef = db.collection(collectionPath.rawValue).document(docID)
		return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[String: Any]?, Error>) in
			documentRef.getDocument { (snapshot, error) in
				if let error = error {
					continuation.resume(throwing: error)
				} else {
					if let data = snapshot?.data() {
						continuation.resume(returning: data)
					} else {
						continuation.resume(returning: nil)
					}
				}
			}
		}
	}
	
	// MARK: - Update
	
	func update(
		collectionPath: CollectionPath,
		docID: String,
		updateData: [String: Any]
	) async throws {
		let documentRef = db.collection(collectionPath.rawValue).document(docID)
		try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
			documentRef.updateData(updateData) { error in
				if let error = error {
					continuation.resume(throwing: error)
				} else {
					continuation.resume()
				}
			}
		}
	}
	
	// MARK: - Delete
	
	func delete(
		collectionPath: CollectionPath,
		docID: String
	) async throws {
		let documentRef = db.collection(collectionPath.rawValue).document(docID)
		try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
			documentRef.delete() { error in
				if let error = error {
					continuation.resume(throwing: error)
				} else {
					continuation.resume()
				}
			}
		}
	}
	
	func deleteField(
		collectionPath: CollectionPath,
		docID: String,
		fieldID: String
	) async throws {
		let documentRef = db.collection(collectionPath.rawValue).document(docID)
		try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
			documentRef.updateData([fieldID:""]){ error in
				if let error = error {
					continuation.resume(throwing: error)
				} else {
					continuation.resume()
				}
			}
		}
	}
}
