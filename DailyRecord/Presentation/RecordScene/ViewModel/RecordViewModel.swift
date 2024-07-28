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
																			create_time: Int(Date().millisecondsSince1970),
																			calendar_date: self.calendarDate)
		
		let recordData = try recordRequest.asDictionary()
		
		do {
			try await recordUseCase.createRecord(data: recordData)
		} catch {
			// TODO: 에러 처리
		}
	}
	
	private func uploadImage(_ image: UIImage, userID: String) async throws -> String {
		let storageRef = Storage.storage().reference().child("record/\(userID)/\(UUID().uuidString).jpg")
		guard let imageData = image.jpegData(compressionQuality: 0.1) else {
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
	
	func removeRecordTirgger() async throws {
		do {
			self.calendarDate = selectData.calendarDate
			try await recordUseCase.removeRecord(docID: String(calendarDate))
		} catch {
			// TODO: 에러 처리
		}
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
		let urlStrings = selectData.imageList
		let dispatchGroup = DispatchGroup()
		var loadedImages: [UIImage] = []
		
		for urlString in urlStrings {
			if let url = URL(string: urlString) {
				dispatchGroup.enter()
				loadImage(from: url) { image in
					if let image = image {
						loadedImages.append(image)
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
	
	private func loadImage(from url: URL,
												 completion: @escaping (UIImage?) -> Void) {
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
