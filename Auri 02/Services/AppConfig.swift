import Foundation
import Supabase

enum AppConfig {
    static let supabaseURL = "https://qmuhnllioedastkvhtzy.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFtdWhubGxpb2VkYXN0a3ZodHp5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE5ODY0NjUsImV4cCI6MjA1NzU2MjQ2NX0.caJ5p5aa3lD4As20_bN2yVi4ANSiXv8ClN4Yy5GyVbg"
    
    static let shared = SupabaseClient(
        supabaseURL: URL(string: supabaseURL)!,
        supabaseKey: supabaseAnonKey
    )
}
