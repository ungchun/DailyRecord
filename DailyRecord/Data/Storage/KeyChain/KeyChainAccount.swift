//
//  KeyChainAccount.swift
//  DailyRecord
//
//  Created by Kim SungHun on 8/15/24.
//

import Foundation

enum KeyChainAccount {
	case uid
	case idTokenString
	case nonce
	
	/// 더 필요한 Account 추가
	
	var description: String {
		return String(describing: self)
	}
	
	var keyChainClass: CFString {
		switch self {
		case .uid:
			return kSecClassGenericPassword
		case .idTokenString:
			return kSecClassGenericPassword
		case .nonce:
			return kSecClassGenericPassword
		}
	}
}
