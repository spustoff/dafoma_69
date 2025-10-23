//
//  SettingsView.swift
//  CognityPin
//
//  Created by Вячеслав on 10/13/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var showingExportSheet = false
    @State private var exportedData = ""
    
    init() {
        self._viewModel = StateObject(wrappedValue: SettingsViewModel())
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.cognityBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // User stats section
                        userStatsSection
                        
                        
                        // Data section
                        dataSection
                        
                        // About section
                        aboutSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Delete Account", isPresented: $viewModel.showingDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteAccount()
                }
            } message: {
                Text("This will permanently delete all your data and reset the app. This action cannot be undone.")
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportDataView(data: exportedData)
            }
        }
    }
    
    private var userStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Progress")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.cognityTextPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Articles Read",
                    value: "\(viewModel.totalArticlesRead)",
                    icon: "book.fill",
                    color: .cognityPrimary
                )
                
                StatCard(
                    title: "Reading Time",
                    value: viewModel.totalReadingTime,
                    icon: "clock.fill",
                    color: .cognitySecondary
                )
                
                StatCard(
                    title: "Current Streak",
                    value: viewModel.currentStreak,
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Bookmarked",
                    value: "\(viewModel.bookmarkedCount)",
                    icon: "bookmark.fill",
                    color: .blue
                )
            }
            
            // Daily goal progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Daily Reading Goal")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.cognityTextPrimary)
                    
                    Spacer()
                    
                    Text(viewModel.dailyGoalText)
                        .font(.caption)
                        .foregroundColor(.cognityTextSecondary)
                }
                
                ProgressView(value: viewModel.dailyGoalProgress)
                    .tint(.cognityPrimary)
                    .scaleEffect(y: 2)
            }
            .padding(16)
            .background(Color.cognityCardBackground)
            .cornerRadius(12)
        }
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.cognityTextPrimary)
            
            VStack(spacing: 12) {
                // Color scheme
                SettingsRow(
                    title: "Appearance",
                    subtitle: colorSchemeDescription,
                    icon: "paintbrush.fill",
                    color: .purple
                ) {
                    ColorSchemePickerView(selectedScheme: $viewModel.selectedColorScheme)
                }
                
                // Font size
                SettingsRow(
                    title: "Font Size",
                    subtitle: viewModel.fontSize.description,
                    icon: "textformat.size",
                    color: .blue
                ) {
                    FontSizePickerView(selectedSize: $viewModel.fontSize)
                }
                
                // Daily reading goal
                SettingsRow(
                    title: "Daily Reading Goal",
                    subtitle: "\(viewModel.dailyReadingGoal) articles per day",
                    icon: "target",
                    color: .green
                ) {
                    Stepper("", value: $viewModel.dailyReadingGoal, in: 1...10)
                        .labelsHidden()
                }
                
                // Notifications
                SettingsToggleRow(
                    title: "Reading Reminders",
                    subtitle: "Get notified about new articles",
                    icon: "bell.fill",
                    color: .orange,
                    isOn: $viewModel.readingReminders
                )
            }
        }
    }
    
    
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Management")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.cognityTextPrimary)
            
            VStack(spacing: 12) {
                SettingsRow(
                    title: "Export Data",
                    subtitle: "Download your reading history and preferences",
                    icon: "square.and.arrow.up.fill",
                    color: .blue
                ) {
                    Button("Export") {
                        exportedData = viewModel.exportUserData()
                        showingExportSheet = true
                    }
                    .font(.caption)
                    .foregroundColor(.cognityPrimary)
                }
                
                SettingsRow(
                    title: "Delete Account",
                    subtitle: "Permanently delete all your data",
                    icon: "trash.fill",
                    color: .red
                ) {
                    Button("Delete") {
                        viewModel.showingDeleteAccountAlert = true
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.cognityTextPrimary)
            
            VStack(spacing: 12) {
                SettingsRow(
                    title: "CognityPin",
                    subtitle: "Version 1.0.0",
                    icon: "info.circle.fill",
                    color: .cognityPrimary
                ) {
                    EmptyView()
                }
            }
            
            VStack(spacing: 12) {
                SettingsRow(
                    title: "Medical Data Source",
                    subtitle: "Click for learn",
                    icon: "info.circle.fill",
                    color: .cognityPrimary
                ) {
                    
                }
            }
            .onTapGesture {
                
                UIApplication.shared.open(URL(string: "https://www.cilvektiesibugids.lv/en/themes/data-privacy/medical-data/what-is-medical-data")!)
            }
        }
    }
    
    private var colorSchemeDescription: String {
        switch viewModel.selectedColorScheme {
        case .light: return "Light mode"
        case .dark: return "Dark mode"
        case nil: return "System default"
        @unknown default: return "System default"
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.cognityTextPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.cognityTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.cognityCardBackground)
        .cornerRadius(12)
    }
}

struct SettingsRow<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, subtitle: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.cognityTextPrimary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.cognityTextSecondary)
            }
            
            Spacer()
            
            content
        }
        .padding(16)
        .background(Color.cognityCardBackground)
        .cornerRadius(12)
    }
}

struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool
    
    var body: some View {
        SettingsRow(title: title, subtitle: subtitle, icon: icon, color: color) {
            Toggle("", isOn: $isOn)
                .tint(.cognityPrimary)
        }
    }
}

struct ColorSchemePickerView: View {
    @Binding var selectedScheme: ColorScheme?
    
    var body: some View {
        Menu {
            Button("System Default") {
                selectedScheme = nil
            }
            
            Button("Light Mode") {
                selectedScheme = .light
            }
            
            Button("Dark Mode") {
                selectedScheme = .dark
            }
        } label: {
            HStack {
                Text(schemeTitle)
                    .font(.caption)
                    .foregroundColor(.cognityPrimary)
                
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .foregroundColor(.cognityPrimary)
            }
        }
    }
    
    private var schemeTitle: String {
        switch selectedScheme {
        case .light: return "Light"
        case .dark: return "Dark"
        case nil: return "System"
        @unknown default: return "System"
        }
    }
}

struct FontSizePickerView: View {
    @Binding var selectedSize: FontSize
    
    var body: some View {
        Menu {
            ForEach(FontSize.allCases, id: \.self) { size in
                Button(size.description) {
                    selectedSize = size
                }
            }
        } label: {
            HStack {
                Text(selectedSize.description)
                    .font(.caption)
                    .foregroundColor(.cognityPrimary)
                
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .foregroundColor(.cognityPrimary)
            }
        }
    }
}

struct ExportDataView: View {
    let data: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                Text(data)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.cognityTextPrimary)
                    .padding()
            }
            .background(Color.cognityBackground)
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("Close") {
                    dismiss()
                }.foregroundColor(.cognityPrimary),
                trailing: Button(action: {
                    // Share functionality would be implemented here
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.cognityPrimary)
                }
            )
        }
    }
}


#Preview {
    SettingsView()
}
