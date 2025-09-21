//
//  News.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 22.09.2025.
//

import SwiftUI
import Foundation

struct NewsTextFormatter {
    
    /// Formats news content text by cleaning HTML symbols, removing character counts, and adding show more functionality
    /// - Parameters:
    ///   - content: The raw content text from the news API
    ///   - maxLength: Maximum characters to show before truncating (default: 150)
    /// - Returns: Formatted text with optional "more" button
    static func formatContent(_ content: String?, maxLength: Int = 150) -> (text: String, hasMore: Bool, originalText: String) {
        guard let content = content, !content.isEmpty else {
            return ("", false, "")
        }
        
        // Step 1: Clean HTML/CSS symbols and entities
        let cleanedText = cleanHtmlSymbols(content)
        
        // Step 2: Check if original text had character count pattern
        let charCountPattern = "\\[\\+\\d+\\s*(chars?|characters?)\\]"
        let hadCharCountPattern = cleanedText.range(of: charCountPattern, options: .regularExpression) != nil
        
        // Step 3: Remove character count patterns like "[+212 chars]"
        let textWithoutCharCount = removeCharacterCount(cleanedText)
        
        // Step 4: Check if text needs truncation
        if textWithoutCharCount.count <= maxLength {
            return (textWithoutCharCount, hadCharCountPattern, textWithoutCharCount)
        }
        
        // Step 5: Truncate and add ellipsis
        let truncatedText = String(textWithoutCharCount.prefix(maxLength)).trimmingCharacters(in: .whitespacesAndNewlines)
        let finalText = truncatedText.hasSuffix("...") ? truncatedText : truncatedText + "..."
        
        return (finalText, hadCharCountPattern, textWithoutCharCount)
    }
    
    /// Cleans HTML symbols, entities, and CSS from text
    /// - Parameter text: Raw text that may contain HTML
    /// - Returns: Cleaned text without HTML symbols
    private static func cleanHtmlSymbols(_ text: String) -> String {
        var cleanedText = text
        
        // Remove common HTML entities
        let htmlEntities = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&#39;": "'",
            "&apos;": "'",
            "&nbsp;": " ",
            "&copy;": "©",
            "&reg;": "®",
            "&trade;": "™"
        ]
        
        for (entity, replacement) in htmlEntities {
            cleanedText = cleanedText.replacingOccurrences(of: entity, with: replacement)
        }
        
        // Remove HTML tags (basic pattern)
        cleanedText = cleanedText.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // Remove CSS-style content
        cleanedText = cleanedText.replacingOccurrences(of: "style\\s*=\\s*\"[^\"]*\"", with: "", options: .regularExpression)
        
        // Clean up multiple spaces and newlines
        cleanedText = cleanedText.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        cleanedText = cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleanedText
    }
    
    /// Removes character count patterns like "[+212 chars]" or "[+1234 characters]"
    /// - Parameter text: Text that may contain character count patterns
    /// - Returns: Text without character count patterns
    private static func removeCharacterCount(_ text: String) -> String {
        var cleanedText = text
        
        // Pattern to match "[+XXX chars]" or "[+XXX characters]" at the end
        let charCountPattern = "\\s*\\[\\+\\d+\\s*(chars?|characters?)\\]\\s*$"
        cleanedText = cleanedText.replacingOccurrences(of: charCountPattern, with: "", options: .regularExpression)
        
        // Also handle cases where it might be in the middle of text
        let charCountPatternMiddle = "\\s*\\[\\+\\d+\\s*(chars?|characters?)\\]\\s*"
        cleanedText = cleanedText.replacingOccurrences(of: charCountPatternMiddle, with: " ", options: .regularExpression)
        
        return cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Formats description text (similar to content but shorter default max length)
    /// - Parameters:
    ///   - description: The description text from news API
    ///   - maxLength: Maximum characters to show (default: 100)
    /// - Returns: Formatted description text
    static func formatDescription(_ description: String?, maxLength: Int = 100) -> (text: String, hasMore: Bool, originalText: String) {
        return formatContent(description, maxLength: maxLength)
    }
}

// MARK: - Preview Helper
#Preview {
    VStack(alignment: .leading, spacing: 16) {
        let sampleContent = "This is a sample news article with some content that contains HTML entities like &amp; and &lt;tags&gt; and also has character count [+123 chars] at the end."
        
        let formatted = NewsTextFormatter.formatContent(sampleContent, maxLength: 80)
        
        Text("Original:")
            .font(.caption)
            .foregroundColor(.secondary)
        
        Text(sampleContent)
            .font(.body)
            .foregroundColor(.primary)
        
        Divider()
        
        Text("Formatted:")
            .font(.caption)
            .foregroundColor(.secondary)
        
        Text(formatted.text)
            .font(.body)
            .foregroundColor(.primary)
        
        if formatted.hasMore {
            Text("More")
                .font(.caption)
                .foregroundColor(.blue)
                .underline()
        }
    }
    .padding()
}
