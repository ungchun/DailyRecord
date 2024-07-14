//
//  CalenderRepository.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/13/24.
//

import Firebase
import FirebaseFirestore

final class CalenderRepository: DefaultCalenderRepository {
	private let db = Firestore.firestore()
	private let collectionPath = "calender"
}

extension CalenderRepository {
	
	// TODO: year, month, day 하드코딩 부분 수정 및 테스트 확실히 해볼 필요 있음
	
	func readMonthRecord() async throws -> [RecordResponseDTO] {
			guard let userID = Auth.auth().currentUser?.uid else {
					throw NSError(domain: "AuthError",
												code: 1001,
												userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
			}
			
			let db = Firestore.firestore()
			
			// 월의 시작과 끝을 설정
			var components = DateComponents()
			components.year = 2024
			components.month = 7
			components.day = 1
			let calendar = Calendar.current
			
			guard let startOfMonth = calendar.date(from: components) else {
					throw NSError(domain: "DateError",
												code: 1002,
												userInfo: [NSLocalizedDescriptionKey: "Invalid start of month date"])
			}
			
			components.month = 7 + 1
			components.day = 0
			guard let endOfMonth = calendar.date(from: components) else {
					throw NSError(domain: "DateError",
												code: 1003,
												userInfo: [NSLocalizedDescriptionKey: "Invalid end of month date"])
			}
			
			let startTimestamp = Int(startOfMonth.timeIntervalSince1970 * 1000)
			let endTimestamp = Int(endOfMonth.timeIntervalSince1970 * 1000)
			
			let documentRef = db.collection("user").document(userID).collection("record")
			
			let query = documentRef
					.whereField("calendar_date", isGreaterThanOrEqualTo: startTimestamp)
					.whereField("calendar_date", isLessThanOrEqualTo: endTimestamp)
			
			return try await withCheckedThrowingContinuation { continuation in
					query.getDocuments { (querySnapshot, error) in
							if let error = error {
									continuation.resume(throwing: error)
							} else {
									do {
											var records: [RecordResponseDTO] = []
											for document in querySnapshot!.documents {
													let data = document.data()
													let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
													let recordResponse = try JSONDecoder().decode(RecordResponseDTO.self, from: jsonData)
													records.append(recordResponse)
											}
											continuation.resume(returning: records)
									} catch {
											continuation.resume(throwing: error)
									}
							}
					}
			}
	}
}
