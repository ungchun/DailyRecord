//
//  KeyChainManager.swift
//  DailyRecord
//
//  Created by Kim SungHun on 8/15/24.
//

import Foundation
import Security

final class KeyChainManager {
	static let shared = KeyChainManager()
	static let serviceName = "ungchun.DailyRecord"
	
	private init() { }
	
	func create(account: KeyChainAccount, data: String) throws {
		let query = [
			kSecClass: account.keyChainClass,
			kSecAttrService: KeyChainManager.serviceName,
			kSecAttrAccount: account.description,
			kSecValueData: (data as AnyObject).data(using: String.Encoding.utf8.rawValue) as Any
		] as CFDictionary
		
		SecItemDelete(query as CFDictionary)
		
		let status = SecItemAdd(query as CFDictionary, nil)
		
		guard status == noErr else {
			throw NSError()
		}
	}
	
	func read(account: KeyChainAccount) throws -> String {
		let query = [
			kSecClass: account.keyChainClass,
			kSecAttrService: KeyChainManager.serviceName,
			kSecAttrAccount: account.description,
			kSecReturnData: true
		] as CFDictionary
		
		var dataTypeRef: AnyObject?
		let status = SecItemCopyMatching(query, &dataTypeRef)
		
		guard status != errSecItemNotFound else {
			throw NSError()
		}
		
		if status == errSecSuccess,
			 let item = dataTypeRef as? Data,
			 let data = String(data: item, encoding: String.Encoding.utf8) {
			return data
		} else {
			throw NSError()
		}
	}
	
	func delete(account: KeyChainAccount) throws {
		let query = [
			kSecClass: account.keyChainClass,
			kSecAttrService: KeyChainManager.serviceName,
			kSecAttrAccount: account.description
		] as CFDictionary
		
		let status = SecItemDelete(query)
		
		guard status == errSecSuccess || status == errSecItemNotFound else {
			throw NSError()
		}
	}
}
