import SwiftUI

struct GridItemData {
    let title: String
    let subtitle: String
    let isLarge: Bool
    let isWide: Bool
}

struct GridItemView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer()
            Text(title)
                .font(Theme.newYorkHeadline(20))
                .foregroundColor(.white)
            Text(subtitle)
                .font(Theme.sfProText(14))
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Theme.backgroundSecondary)
        .cornerRadius(15)
    }
}

struct AIContentView: View {
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    private let items = [
        (title: "Mindful Breathing", subtitle: "Basic meditation techniques"),
        (title: "Daily Focus", subtitle: "Concentration exercises"),
        (title: "Weekly Progress", subtitle: "Track your meditation journey"),
        (title: "Guided Sessions", subtitle: "Expert-led meditation series"),
        (title: "Evening Calm", subtitle: "Relaxation practice"),
        (title: "Morning Light", subtitle: "Start your day mindfully"),
        (title: "Advanced Practice", subtitle: "Deep meditation techniques"),
        (title: "Quick Reset", subtitle: "5-minute mindfulness break")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        GridItemView(title: item.title, subtitle: item.subtitle)
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
                .padding(16)
            }
            .background(Theme.backgroundPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Mindfulness")
                        .font(Theme.newYorkHeadline(20))
                        .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AIContentView()
}
