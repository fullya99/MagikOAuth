import SwiftUI

// MARK: - OAuth Param Classifier
//
//  Maps OAuth parameter keys to Aurora spectrum colors.
//  The "Prism" concept: URL light decomposed into colored spectrum.
//
//    code, token       → violet  (secrets/credentials)
//    redirect_uri      → cyan    (redirections)
//    scope, audience   → amber   (permissions)
//    state, nonce      → rose    (security/ephemeral)
//    client_id, iss    → teal    (identifiers)
//    unknown           → secondary text color

enum AuroraColor {
    case teal
    case cyan
    case violet
    case rose
    case amber
    case `default`

    var color: Color {
        switch self {
        case .teal: AppTheme.Aurora.teal
        case .cyan: AppTheme.Aurora.cyan
        case .violet: AppTheme.Aurora.violet
        case .rose: AppTheme.Aurora.rose
        case .amber: AppTheme.Aurora.amber
        case .default: AppTheme.Text.secondary
        }
    }
}

enum OAuthParamClassifier {
    private static let mapping: [String: AuroraColor] = [
        // Secrets / credentials → violet
        "code": .violet,
        "access_token": .violet,
        "id_token": .violet,
        "token": .violet,
        "refresh_token": .violet,
        "code_verifier": .violet,
        "code_challenge": .violet,
        "assertion": .violet,

        // Redirects → cyan
        "redirect_uri": .cyan,
        "redirect_url": .cyan,
        "callback": .cyan,
        "post_logout_redirect_uri": .cyan,
        "login_hint": .cyan,

        // Permissions / scope → amber
        "scope": .amber,
        "audience": .amber,
        "resource": .amber,
        "response_type": .amber,
        "response_mode": .amber,
        "grant_type": .amber,
        "code_challenge_method": .amber,
        "prompt": .amber,
        "access_type": .amber,

        // Security / ephemeral → rose
        "state": .rose,
        "nonce": .rose,
        "session_state": .rose,
        "error": .rose,
        "error_description": .rose,

        // Identifiers → teal
        "client_id": .teal,
        "client_secret": .teal,
        "tenant": .teal,
        "iss": .teal,
        "sub": .teal,
        "aud": .teal,
    ]

    static func classify(_ key: String) -> AuroraColor {
        mapping[key] ?? .default
    }
}
