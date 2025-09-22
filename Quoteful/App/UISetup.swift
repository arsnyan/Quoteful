//
//  UISetup.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 22.09.2025.
//

import SwiftUI

// Might reuse for different color in different tabs
@MainActor
func setTabBarItemColor(selected: Color, unselected: Color) {
    let uiSelected = UIColor(selected)
    let uiUnselected = UIColor(unselected)
    
    let appearance = UITabBarAppearance()
    
    appearance.stackedLayoutAppearance.selected.iconColor = uiSelected
    
    if #unavailable(iOS 26.0) {
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: uiSelected
        ]
        
        appearance.stackedLayoutAppearance.normal.iconColor = uiUnselected
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: uiUnselected
        ]
    }
    
    UITabBar.appearance().standardAppearance = appearance
    UITabBar.appearance().scrollEdgeAppearance = appearance
}
