import SwiftUI

struct MoodCard: View {
    let mood: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Mood")
                .font(Theme.newYorkHeadline(20))
                .foregroundColor(.white)
            Text(description)
                .font(Theme.sfProText(14))
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.backgroundSecondary)
        .cornerRadius(16)
    }
}
