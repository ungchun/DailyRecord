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
	var imageList: [(String, UIImage)] = [] // 첨부 이미지와 식별자
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
	
	func createRecordTirgger() async throws {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		var createImageListValue: [(String, String)] = []
		self.calendarDate = selectData.calendarDate
		
		for (identifier, image) in self.imageList {
			let imageUrl = try await uploadImage(image, userID: userID)
			createImageListValue.append((identifier, imageUrl))
		}
		
		let recordRequest = RecordRequest(
			user_id: userID,
			content: self.content,
			emotion_type: emotionType.rawValue,
			image_list: createImageListValue.map{$0.1},
			image_identifier: createImageListValue.map{$0.0},
			create_time: Int(Date().millisecondsSince1970),
			calendar_date: self.calendarDate
		)
		
		let recordData = try recordRequest.asDictionary()
		
		try await recordUseCase.createRecord(data: recordData)
	}
	
	private func uploadImage(_ image: UIImage, userID: String) async throws -> String {
		let storageRef
		= Storage.storage().reference().child("record/\(userID)/\(UUID().uuidString).jpg")
		guard let imageData = image.jpegData(compressionQuality: 0.1) else {
			throw NSError(
				domain: "ImageConversionError",
				code: 1001,
				userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG data."])
		}
		
		return try await withCheckedThrowingContinuation { continuation in
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
	
	func removeRecordTirgger() async throws {
		self.calendarDate = selectData.calendarDate
		try await recordUseCase.removeRecord(docID: String(calendarDate))
	}
}

extension RecordViewModel {
	func setNotImageData(completion: @escaping () -> Void) {
		content = selectData.content
		emotionType = selectData.emotionType
		createTime = selectData.createTime
		completion()
	}
	
	func setImageData(completion: @escaping () -> Void) {
		let urlStrings = selectData.imageListURL
		let imageIdentifiers = selectData.imageIdentifiers
		let dispatchGroup = DispatchGroup()
		var loadedImages: [(String, UIImage)] = Array(repeating: ("", UIImage()),
																									count: urlStrings.count)
		
		for idx in urlStrings.indices {
			if let url = URL(string: urlStrings[idx]) {
				dispatchGroup.enter()
				loadImage(from: url) { image in
					if let image = image {
						if urlStrings.count == imageIdentifiers.count {
							loadedImages[idx] = (imageIdentifiers[idx], image)
						} else {
							loadedImages[idx] = ("", image)
						}
					}
					dispatchGroup.leave()
				}
			}
		}
		
		dispatchGroup.notify(queue: .main) {
			self.imageList = loadedImages
			completion()
		}
	}
	
	private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
		URLSession.shared.dataTask(with: url) { data, response, error in
			if let data = data, error == nil {
				let image = UIImage(data: data)
				DispatchQueue.main.async {
					completion(image)
				}
			} else {
				DispatchQueue.main.async {
					completion(nil)
				}
			}
		}.resume()
	}
}
