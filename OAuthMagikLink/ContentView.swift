import SwiftUI

// MARK: - Content View
//
//  Main panel UI for MagikOAuth.
//  Pure rendering — all logic lives in URLViewModel.
//
//  Layout:
//    ┌─ Header ──────────────────────────────┐
//    │  ◇ MagikOAuth              ♡  ⟲  ⌘Q  │
//    ├───────────────────────────────────────┤
//    │  PASTE RAW LINK              [Paste]  │
//    │  ┌─ GlassCard (input) ──────────────┐ │
//    │  │  https://...                      │ │
//    │  └──────────────────────────────────┘ │
//    │                                       │
//    │  ✓ CLEANED URL            [Inspect]   │
//    │  ┌─ Click to copy ──────────────────┐ │
//    │  │  https://clean.url          📋   │ │
//    │  └──────────────────────────────────┘ │
//    │                                       │
//    │  [ ⌘C Copy ]  [ ↗ Open ]              │
//    └───────────────────────────────────────┘

struct ContentView: View {
    @Bindable var viewModel: URLViewModel

    /// Ko-fi donation URL
    private let donationURL = "https://ko-fi.com/fullya"

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().background(AppTheme.Background.border).opacity(0.3)

            VStack(spacing: AppTheme.Spacing.lg) {
                inputSection

                if viewModel.isValid {
                    outputSection
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    actionButtons
                        .transition(.opacity)
                }

                if let errorMsg = viewModel.errorMessage {
                    errorBanner(errorMsg)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .padding(AppTheme.Spacing.lg)
        }
        .frame(width: AppTheme.Panel.width)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxHeight: AppTheme.Panel.maxHeight)
        .clipped()
        .background(AppTheme.Background.base)
        .preferredColorScheme(.dark)
        .animation(AppTheme.Animation.spring, value: viewModel.isValid)
        .animation(AppTheme.Animation.spring, value: viewModel.errorState)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "diamond.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.Aurora.titleGradient)

            Text("MagikOAuth")
                .font(AppTheme.Fonts.title)
                .foregroundStyle(AppTheme.Aurora.titleGradient)

            Spacer()

            // Donation
            Button {
                if let url = URL(string: donationURL) {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                Image(systemName: "heart")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.Aurora.rose.opacity(0.7))
            }
            .buttonStyle(.plain)
            .help("Support MagikOAuth")
            .accessibilityLabel("Donate")

            // Reset
            Button {
                withAnimation(AppTheme.Animation.spring) {
                    viewModel.reset()
                }
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.Text.secondary)
            }
            .buttonStyle(.plain)
            .help("Reset")
            .accessibilityLabel("Reset")

            // Quit
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Text.tertiary)
            }
            .buttonStyle(.plain)
            .help("Quit MagikOAuth")
            .accessibilityLabel("Quit application")
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Label("Paste raw link", systemImage: "doc.on.clipboard")
                    .font(AppTheme.Fonts.captionLabel)
                    .foregroundColor(AppTheme.Text.secondary)

                Spacer()

                if viewModel.hasInput {
                    Button {
                        withAnimation(AppTheme.Animation.fast) {
                            viewModel.reset()
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 9))
                            Text("Clear")
                                .font(AppTheme.Fonts.caption)
                        }
                        .foregroundColor(AppTheme.Text.tertiary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear input")
                } else {
                    Button {
                        viewModel.pasteFromClipboard()
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "clipboard")
                                .font(.system(size: 9))
                            Text("Paste")
                                .font(AppTheme.Fonts.caption)
                        }
                        .foregroundColor(AppTheme.Text.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Paste from clipboard")
                }
            }

            ZStack(alignment: .topLeading) {
                if viewModel.inputText.isEmpty {
                    Text("Paste or copy any OAuth URL...")
                        .font(AppTheme.Fonts.code)
                        .foregroundColor(AppTheme.Text.disabled)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                }

                TextEditor(text: $viewModel.inputText)
                    .font(AppTheme.Fonts.code)
                    .foregroundColor(AppTheme.Text.primary)
                    .scrollContentBackground(.hidden)
                    .padding(4)
                    .accessibilityLabel("URL input field")
                    .accessibilityHint("Paste or type the OAuth URL to clean")
            }
            .frame(height: 72)
            .background(AppTheme.Background.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(
                        viewModel.errorState != nil && viewModel.errorState != .empty
                            ? AppTheme.Aurora.rose.opacity(0.3)
                            : AppTheme.Background.border.opacity(0.5),
                        lineWidth: 1
                    )
            )
            .modifier(ShakeModifier(trigger: viewModel.errorState != nil && viewModel.errorState != .empty && viewModel.errorState != .tooLong))
        }
    }

    // MARK: - Output Section

    private var outputSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Label("Cleaned URL", systemImage: "checkmark.seal.fill")
                    .font(AppTheme.Fonts.captionLabel)
                    .foregroundColor(AppTheme.Aurora.teal)

                Spacer()

                Button {
                    withAnimation(AppTheme.Animation.normal) {
                        viewModel.showParsed.toggle()
                    }
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: viewModel.showParsed ? "link" : "list.bullet")
                            .font(.system(size: 9))
                        Text(viewModel.showParsed ? "URL" : "Inspect")
                            .font(AppTheme.Fonts.caption)
                    }
                    .foregroundColor(AppTheme.Text.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(viewModel.showParsed ? "Show URL" : "Inspect parameters")
            }

            if viewModel.showParsed {
                ParamsView(
                    baseEndpoint: viewModel.baseEndpoint,
                    params: viewModel.params
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                Button(action: viewModel.copyToClipboard) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Text(viewModel.cleanedURL)
                            .font(AppTheme.Fonts.code)
                            .foregroundColor(AppTheme.Text.primary.opacity(0.85))
                            .lineLimit(3)
                            .truncationMode(.middle)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: viewModel.copied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 10))
                            .foregroundColor(viewModel.copied ? AppTheme.Aurora.teal : AppTheme.Text.tertiary)
                    }
                    .padding(AppTheme.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glass()
                }
                .buttonStyle(.plain)
                .help("Click to copy")
                .transition(.opacity.combined(with: .move(edge: .top)))
                .accessibilityLabel("Cleaned URL. Click to copy.")
            }

            if viewModel.wasTruncated {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 9))
                    Text("URL truncated (too long)")
                        .font(AppTheme.Fonts.caption)
                }
                .foregroundColor(AppTheme.Aurora.amber)
                .accessibilityLabel("Warning: URL was truncated because it's too long")
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        GlassButton(
            title: "Open in browser",
            icon: "arrow.up.right",
            style: .secondary,
            action: viewModel.openInBrowser
        )
        .accessibilityLabel("Open URL in browser")
        .keyboardShortcut("o", modifiers: .command)
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 11))
                .foregroundColor(AppTheme.Aurora.rose)
            Text(message)
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Aurora.rose)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Aurora.rose.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(AppTheme.Aurora.rose.opacity(0.15), lineWidth: 1)
        )
        .accessibilityLabel("Error: \(message)")
    }
}

// MARK: - Shake Animation Modifier

struct ShakeModifier: ViewModifier {
    var trigger: Bool
    @State private var shakeOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: shakeOffset)
            .onChange(of: trigger) { _, newValue in
                guard newValue else { return }
                withAnimation(.default) {
                    let shakeSequence = [0, -6, 6, -4, 4, -2, 2, 0]
                    for (index, offset) in shakeSequence.enumerated() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.04) {
                            withAnimation(.linear(duration: 0.04)) {
                                shakeOffset = CGFloat(offset)
                            }
                        }
                    }
                }
            }
    }
}

#Preview {
    ContentView(viewModel: URLViewModel())
        .frame(width: 460, height: 400)
}
