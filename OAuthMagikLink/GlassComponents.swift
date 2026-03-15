import SwiftUI

// MARK: - Glass Design System
//
//  Dual-path glass rendering:
//    macOS 26+ → native .glassEffect()
//    macOS 14-25 → custom layered composition (gradient stroke + shadow + fill)
//
//  Usage:
//    anyView.glass()              // default card style
//    anyView.glass(tint: .teal)   // tinted glass (e.g. success state)

struct GlassModifier: ViewModifier {
    var tint: Color?
    var cornerRadius: CGFloat = AppTheme.Glass.cornerRadius

    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content
                .glassEffect(.regular.tint(tint ?? .clear), in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(glassBackground)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(glassBorder)
                .shadow(
                    color: AppTheme.Glass.shadowColor,
                    radius: AppTheme.Glass.shadowRadius,
                    y: AppTheme.Glass.shadowY
                )
        }
    }

    private var glassBackground: some View {
        Group {
            if let tint {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(tint.opacity(0.08))
            } else {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.Glass.fill)
            }
        }
    }

    private var glassBorder: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(AppTheme.Aurora.glassStroke, lineWidth: AppTheme.Glass.borderWidth)
    }
}

extension View {
    func glass(tint: Color? = nil, cornerRadius: CGFloat = AppTheme.Glass.cornerRadius) -> some View {
        modifier(GlassModifier(tint: tint, cornerRadius: cornerRadius))
    }
}

// MARK: - GlassCard

/// A glass container for content sections (input, output, params).
struct GlassCard<Content: View>: View {
    var tint: Color?
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(AppTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glass(tint: tint)
    }
}

// MARK: - GlassButton

/// A glass-styled action button with hover state.
struct GlassButton: View {
    let title: String
    let icon: String
    var style: Style = .secondary
    var action: () -> Void

    @State private var isHovered = false

    enum Style {
        case primary
        case secondary

        var foreground: Color {
            switch self {
            case .primary: AppTheme.Aurora.teal
            case .secondary: AppTheme.Text.secondary
            }
        }

        var background: Color {
            switch self {
            case .primary: AppTheme.Aurora.teal
            case .secondary: Color.white
            }
        }

        var backgroundOpacity: CGFloat {
            switch self {
            case .primary: 0.12
            case .secondary: 0.04
            }
        }

        var hoverOpacity: CGFloat {
            switch self {
            case .primary: 0.20
            case .secondary: 0.08
            }
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                Text(title)
                    .font(AppTheme.Fonts.button)
            }
            .foregroundColor(style.foreground)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Button.height)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Button.cornerRadius, style: .continuous)
                    .fill(style.background.opacity(isHovered ? style.hoverOpacity : style.backgroundOpacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Button.cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(isHovered ? 0.08 : 0.04), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(AppTheme.Animation.fast) {
                isHovered = hovering
            }
        }
    }
}
