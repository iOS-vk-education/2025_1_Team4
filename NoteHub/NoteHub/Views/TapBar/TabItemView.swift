//
//  TabItemView.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 19.11.2025.
//

import Foundation
import SwiftUI

struct TabItemView: View {
    let title: String
    let isActive: Bool
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.system(size: 20))
                .foregroundColor(isActive ? .black : .gray)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(isActive ? .black : .gray)
        }
    }
}
