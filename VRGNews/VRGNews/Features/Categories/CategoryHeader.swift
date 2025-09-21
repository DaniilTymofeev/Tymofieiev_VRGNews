//
//  CategoryHeader.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 18.09.2025.
//

import SwiftUI

struct CategoryHeader: View {
    let selectedCategory: Category
    let onCategoryTapped: () -> Void
    
    var body: some View {
        Button(action: onCategoryTapped) {
            HStack {
                Text(selectedCategory.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(selectedCategory.color)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 16)
    }
}

struct CategoryPickerView: View {
    let selectedCategory: Category
    let onCategorySelected: (Category) -> Void
    let onDismiss: () -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Select Category")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Done") {
                    onDismiss()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            
            Divider()
            
            // Categories grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Category.allCases, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: category == selectedCategory,
                            onTap: {
                                onCategorySelected(category)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
}

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(category.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(category.color.opacity(isSelected ? 0.3 : 0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(category.color, lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Category Extensions
extension Category {
    var displayName: String {
        switch self {
        case .general:
            return "General"
        case .business:
            return "Business"
        case .entertainment:
            return "Entertainment"
        case .health:
            return "Health"
        case .science:
            return "Science"
        case .sports:
            return "Sports"
        case .technology:
            return "Technology"
        }
    }
    
    var color: Color {
        switch self {
        case .general:
            return .blue
        case .business:
            return .green
        case .entertainment:
            return .yellow
        case .health:
            return .red
        case .science:
            return .purple
        case .sports:
            return .orange
        case .technology:
            return .blue
        }
    }
}

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    VStack {
        CategoryHeader(
            selectedCategory: .general,
            onCategoryTapped: {}
        )
        
        Spacer()
    }
}
