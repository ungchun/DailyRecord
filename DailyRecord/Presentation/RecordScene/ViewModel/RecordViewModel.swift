//
//  RecordViewModel.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/15/24.
//

import UIKit

import FirebaseAuth
import FirebaseStorage

final class RecordViewModel: BaseViewModel {
	
	// MARK: - Properties
	
	private let recordUseCase: DefaultRecordUseCase
	
	var selectData: RecordEntity
	
	var content: String = "" // 글 내용
	var imageList: [UIImage] = [] // 첨부 이미지
	var emotionType: EmotionType = .none
	
	private var calendarDate: Int = 0 // 선택 날짜
	private var createTime: Int = 0 // 생성(수정) 시간
	
	// MARK: - Init
	
	init(
		recordUseCase: DefaultRecordUseCase,
		selectData: RecordEntity
	) {
		self.recordUseCase = recordUseCase
		self.selectData = selectData
	}
}

extension RecordViewModel {
	
	// MARK: - Functions
	
	@MainActor
	func createRecordTirgger() async throws {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		var imageUrls: [String] = []
		self.calendarDate = selectData.calendarDate
		
		// 이미지 리스트를 업로드하고 URL을 배열에 저장
		for image in self.imageList {
			let imageUrl = try await uploadImage(image, userID: userID)
			imageUrls.append(imageUrl)
		}
		
		let recordRequest = RecordRequest(user_id: userID,
																			content: self.content,
																			emotion_type: emotionType.rawValue,
																			image_list: imageUrls,
																			create_time: self.createTime,
																			calendar_date: self.calendarDate)
		
		let recordData = try recordRequest.asDictionary()
		
		do {
			try await recordUseCase.createRecord(data: recordData)
		} catch {
			// TODO: 에러 처리
		}
	}
	
	// TODO: 이미지 올릴 때 퀄리티 좀 낮춰서 올리기
	func uploadImage(_ image: UIImage, userID: String) async throws -> String {
		let storageRef = Storage.storage().reference().child("record/\(userID)/\(UUID().uuidString).jpg")
		guard let imageData = image.jpegData(compressionQuality: 0.8) else {
			throw NSError(
				domain: "ImageConversionError",
				code: 1001,
				userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG data."])
		}
		
		return try await withCheckedThrowingContinuation {
			(continuation: CheckedContinuation<String, Error>) in
			storageRef.putData(imageData, metadata: nil) { metadata, error in
				if let error = error {
					continuation.resume(throwing: error)
				} else {
					storageRef.downloadURL { url, error in
						if let error = error {
							continuation.resume(throwing: error)
						} else if let url = url {
							continuation.resume(returning: url.absoluteString)
						}
					}
				}
			}
		}
	}
}
