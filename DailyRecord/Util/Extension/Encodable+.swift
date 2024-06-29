//
//  Encodable+.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/29/24.
//

import Foundation

extension Encodable {
	func asDictionary() throws -> [String: Any] {
		let data = try JSONEncoder().encode(self)
		let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
		guard let dictionary = json as? [String: Any] else {
			throw NSError(
				domain: "",
				code: -1,
				userInfo: [NSLocalizedDescriptionKey: "Failed to convert to dictionary"]
			)
		}
		return dictionary
	}
}
