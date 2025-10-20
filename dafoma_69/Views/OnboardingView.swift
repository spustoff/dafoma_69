//
//  OnboardingView.swift
//  CognityPin
//
//  Created by Вячеслав on 10/13/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                Color.cognityBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress indicator
                    HStack {
                        ForEach(0..<viewModel.onboardingPages.count, id: \.self) { index in
                            Capsule()
                                .fill(index <= viewModel.currentPage ? Color.cognityPrimary : Color.gray.opacity(0.3))
                                .frame(height: 4)
                                .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Skip button
                    HStack {
                        Spacer()
                        if !viewModel.isLastPage {
                            Button("Skip") {
                                viewModel.skipToEnd()
                            }
                            .foregroundColor(.cognityTextSecondary)
                            .padding(.trailing, 20)
                        }
                    }
                    .padding(.top, 10)
                    
                    // Page content
                    TabView(selection: $viewModel.currentPage) {
                        ForEach(0..<viewModel.onboardingPages.count, id: \.self) { index in
                            OnboardingPageView(
                                page: viewModel.onboardingPages[index],
                                isLastPage: index == viewModel.onboardingPages.count - 1,
                                viewModel: viewModel
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                let translation = value.translation
                                if translation.width > threshold && viewModel.currentPage > 0 {
                                    viewModel.previousPage()
                                } else if translation.width < -threshold && viewModel.currentPage < viewModel.onboardingPages.count - 1 {
                                    viewModel.nextPage()
                                }
                                dragOffset = .zero
                            }
                    )
                    
                    // Navigation buttons
                    HStack(spacing: 20) {
                        if !viewModel.isFirstPage {
                            Button(action: viewModel.previousPage) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .foregroundColor(.cognityTextSecondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.cognityCardBackground)
                                .cornerRadius(25)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: viewModel.nextPage) {
                            HStack {
                                Text(viewModel.isLastPage ? "Get Started" : "Next")
                                if !viewModel.isLastPage {
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.cognityPrimary)
                            .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isLastPage: Bool
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(page.color)
                .scaleEffect(1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.currentPage)
            
            VStack(spacing: 16) {
                // Title
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.cognityTextPrimary)
                    .multilineTextAlignment(.center)
                
                // Subtitle
                Text(page.subtitle)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(page.color)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.cognityTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
            }
            
            // Configuration options for last page
            if isLastPage {
                VStack(spacing: 20) {
                    // Color scheme selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Appearance")
                            .font(.headline)
                            .foregroundColor(.cognityTextPrimary)
                        
                        HStack(spacing: 12) {
                            ForEach([nil, ColorScheme.light, ColorScheme.dark], id: \.self) { scheme in
                                Button(action: {
                                    viewModel.selectedColorScheme = scheme
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: schemeIcon(for: scheme))
                                            .font(.title2)
                                        Text(schemeTitle(for: scheme))
                                            .font(.caption)
                                    }
                                    .foregroundColor(viewModel.selectedColorScheme == scheme ? .white : .cognityTextSecondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        viewModel.selectedColorScheme == scheme ? 
                                        Color.cognityPrimary : Color.cognityCardBackground
                                    )
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    // Notifications toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Reading Reminders")
                                .font(.headline)
                                .foregroundColor(.cognityTextPrimary)
                            Text("Get notified about new articles")
                                .font(.caption)
                                .foregroundColor(.cognityTextSecondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.notificationsEnabled)
                            .tint(.cognityPrimary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.cognityCardBackground)
                    .cornerRadius(12)
                    
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private func schemeIcon(for scheme: ColorScheme?) -> String {
        switch scheme {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case nil: return "gearshape.fill"
        }
    }
    
    private func schemeTitle(for scheme: ColorScheme?) -> String {
        switch scheme {
        case .light: return "Light"
        case .dark: return "Dark"
        case nil: return "System"
        }
    }
}

#Preview {
    OnboardingView()
}
