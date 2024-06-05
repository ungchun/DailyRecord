//
//  Coordinator.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/2/24.
//

import Foundation

protocol Coordinator: AnyObject {
	associatedtype DIContainerProtocol: DIContainer
	var DIContainer: DIContainerProtocol { get }
	
	func start()
}

extension Coordinator {
	
}
