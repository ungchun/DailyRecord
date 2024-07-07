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
