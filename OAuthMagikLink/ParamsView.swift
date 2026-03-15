import SwiftUI

// MARK: - Params View
//
//  Syntax-highlighted OAuth parameter inspector.
//  The "Prism" decomposition: each param type gets its Aurora color.
//
//  Layout:
//    endpoint  https://accounts.google.com/o/oauth2/auth
//    ─────────────────────────────────────────────────────
//    code       4/0AQlEd8x...    ← violet
//    redirect   https://myapp     ← cyan
//    scope      openid email      ← amber
//    state      xYz9k2...         ← rose

struct ParamsView: View {
    let baseEndpoint: String
    let params: [URLViewModel.OAuthParam]

    @State private var hoveredIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Base endpoint row
            paramRow(
                key: "endpoint",
                value: baseEndpoint,
                keyColor: AppTheme.Aurora.violet,
                isFirst: true
            )

            // OAuth params
            ForEach(Array(params.enumerated()), id: \.element.id) { index, param in
                Divider()
                    .background(AppTheme.Background.border)
                    .opacity(0.5)

                paramRow(
                    key: param.key,
                    value: param.decodedValue,
                    keyColor: param.color.color,
                    isHighlighted: hoveredIndex == index
                )
                .onHover { hovering in
                    withAnimation(AppTheme.Animation.fast) {
                        hoveredIndex = hovering ? index : nil
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(param.key): \(param.decodedValue)")
            }
        }
        .glass()
    }

    // MARK: - Param Row

    private func paramRow(
        key: String,
        value: String,
        keyColor: Color,
        isFirst: Bool = false,
        isHighlighted: Bool = false
    ) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
            Text(key)
                .font(AppTheme.Fonts.codeSmall)
                .fontWeight(.semibold)
                .foregroundColor(keyColor)
                .frame(width: 100, alignment: .trailing)
                .lineLimit(1)

            Text(value)
                .font(AppTheme.Fonts.codeSmall)
                .foregroundColor(AppTheme.Text.primary.opacity(0.75))
                .lineLimit(isFirst ? 1 : 2)
                .truncationMode(.middle)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, AppTheme.Spacing.xs + 2)
        .padding(.horizontal, AppTheme.Spacing.md)
        .background(
            isHighlighted
                ? keyColor.opacity(0.06)
                : (isFirst ? AppTheme.Background.card.opacity(0.3) : Color.clear)
        )
    }
}
