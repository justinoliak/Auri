import SwiftUI

struct EntryCard: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Theme.newYorkHeadline(16))
                .foregroundColor(.white)
            Text(content)
                .font(Theme.sfProText(14))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.backgroundSecondary)
        .cornerRadius(16)
    }
}

#Preview {
    EntryCard(title: "Entry", content: "Sample content")
        .padding()
        .background(Theme.backgroundPrimary)
        .preferredColorScheme(.dark)
}
