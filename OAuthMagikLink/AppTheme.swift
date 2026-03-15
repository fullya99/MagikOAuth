import SwiftUI

// MARK: - MagikOAuth Design System — "Prism / Aurora Dark"
//
//  Palette:
//    Backgrounds:  #0D0D12 (base) → #16161D (surface) → #1C1C26 (card) → #242430 (hover)
//    Aurora:       Teal #00D4AA / Cyan #00B4D8 / Violet #8B5CF6 / Rose #F472B6 / Amber #FBBF24
//    Glass:        fill white 4%, stroke gradient 12%→4%, shadow black 25%, blur 20
//    Text:         #F0F0F5 (primary) / #8B8B9E (secondary) / #55556A (tertiary)

enum AppTheme {
    // MARK: - Backgrounds
    enum Background {
        static let base = Color(hex: 0x0D0D12)
        static let surface = Color(hex: 0x16161D)
        static let card = Color(hex: 0x1C1C26)
        static let hover = Color(hex: 0x242430)
        static let border = Color(hex: 0x2A2A3A)
    }

    // MARK: - Aurora Accent Colors
    enum Aurora {
        static let teal = Color(hex: 0x00D4AA)
        static let cyan = Color(hex: 0x00B4D8)
        static let violet = Color(hex: 0x8B5CF6)
        static let rose = Color(hex: 0xF472B6)
        static let amber = Color(hex: 0xFBBF24)

        /// Title gradient: teal → violet
        static let titleGradient = LinearGradient(
            colors: [teal, violet],
            startPoint: .leading,
            endPoint: .trailing
        )

        /// Subtle border gradient for glass components
        static let glassStroke = LinearGradient(
            colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Text Colors
    enum Text {
        static let primary = Color(hex: 0xF0F0F5)
        static let secondary = Color(hex: 0x8B8B9E)
        static let tertiary = Color(hex: 0x55556A)
        static let disabled = Color(hex: 0x3A3A4A)
        static let link = Aurora.teal
    }

    // MARK: - Glass Properties
    enum Glass {
        static let fill = Color.white.opacity(0.04)
        static let fillHover = Color.white.opacity(0.08)
        static let fillPress = Color.white.opacity(0.12)
        static let shadowColor = Color.black.opacity(0.25)
        static let shadowRadius: CGFloat = 24
        static let shadowY: CGFloat = 8
        static let cornerRadius: CGFloat = 12
        static let borderWidth: CGFloat = 1
    }

    // MARK: - Fonts
    enum Fonts {
        static let title = Font.system(size: 15, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 12, weight: .regular)
        static let bodyMedium = Font.system(size: 12, weight: .medium)
        static let code = Font.system(size: 11, design: .monospaced)
        static let codeSmall = Font.system(size: 10, design: .monospaced)
        static let caption = Font.system(size: 10, weight: .medium)
        static let captionLabel = Font.system(size: 11, weight: .medium)
        static let button = Font.system(size: 12, weight: .medium)
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }

    // MARK: - Panel
    enum Panel {
        static let width: CGFloat = 460
        static let minHeight: CGFloat = 220
        static let maxHeight: CGFloat = 620
        static let cornerRadius: CGFloat = 14
        static let shadowRadius: CGFloat = 48
        static let shadowOpacity: Double = 0.40
    }

    // MARK: - Animation
    enum Animation {
        static let fast = SwiftUI.Animation.easeInOut(duration: 0.15)
        static let normal = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.8)
        static let panelResize = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.85)
    }

    // MARK: - Button
    enum Button {
        static let height: CGFloat = 36
        static let cornerRadius: CGFloat = 8
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
