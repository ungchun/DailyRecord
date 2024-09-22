//
//  WidgetBundle.swift
//  Widget
//
//  Created by Kim SungHun on 9/21/24.
//

import WidgetKit
import SwiftUI

import Firebase

@main
struct DailyRecordWidgetBundle: WidgetBundle {
	
	init() {
	 FirebaseApp.configure()
	 try? Auth.auth().useUserAccessGroup("group.ungchun.DailyRecord")
	}
	
	var body: some Widget {
		DailyRecordWidget()
	}
}
