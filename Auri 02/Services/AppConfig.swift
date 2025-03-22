import Foundation
import Supabase

enum AppConfig {
    // MARK: - Configuration
    
    private static var supabaseConfig: (url: String, key: String) {
        #if DEBUG
        // Development configuration
        guard let path = Bundle.main.path(forResource: "Config-Debug", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let url = config["SUPABASE_URL"] as? String,
              let key = config["SUPABASE_KEY"] as? String
        else {
            fatalError("Missing development configuration. Please add Config-Debug.plist")
        }
        return (url, key)
        #else
        // Production configuration
        guard let url = ProcessInfo.processInfo.environment["SUPABASE_URL"],
              let key = ProcessInfo.processInfo.environment["SUPABASE_KEY"]
        else {
            fatalError("Missing production configuration. Please set environment variables")
        }
        return (url, key)
        #endif
    }
    
    // MARK: - Shared Instances
    
    static let shared: SupabaseClient = {
        let client = SupabaseClient(
            supabaseURL: URL(string: supabaseConfig.url)!,
            supabaseKey: supabaseConfig.key
        )
        return client
    }()
}
