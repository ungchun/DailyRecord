//
//  RecordRequest.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/7/24.
//

import Foundation

struct RecordEntity {
  let content: String
  let emotionType: String
  let imageList: [Data]
  let imageIdentifier: [String]
  let createTime: Int
  let calendarDate: Int
  
  init(
    content: String = "",
    emotionType: String = "",
    imageList: [Data] = [],
    imageIdentifier: [String] = [],
    createTime: Int = 0,
    calendarDate: Int = 0
  ) {
    self.content = content
    self.emotionType = emotionType
    self.imageList = imageList
    self.imageIdentifier = imageIdentifier
    self.createTime = createTime
    self.calendarDate = calendarDate
  }
}
