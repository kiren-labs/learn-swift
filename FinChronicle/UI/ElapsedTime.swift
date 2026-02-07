//
//  ElapsedTime.swift
//  FinChronicle
//
//  Created by Kiren Paul on 3/2/26.
//


import SwiftUI

struct ElapsedTime: View {
    let startTime: Date
    let endTime: Date?
    
    var body: some View {
        if let endTime {
            Text(endTime, format: .offset(to: startTime, allowedFields: [.minute, .second]))

        } else {
            Text(.now, format: .offset(to: startTime, allowedFields: [.minute, .second]))
        }
    }
}

//#Preview {
//    ElapsedTime()
//}
