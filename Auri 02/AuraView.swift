import SwiftUI

struct AuraView: View {
    let onTap: () -> Void
    let onRecordingChange: (Bool) -> Void
    
    @State private var isPressed = false
    @State private var isPersistent = false
    @State private var timer: Timer?
    
    var body: some View {
        WaveView(isPressed: isPressed)
            .frame(width: 200, height: 200)
            .contentShape(Circle())
            .onTapGesture {
                onTap()
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isPressed = true
                            }
                            onRecordingChange(true)
                            timer?.invalidate()
                            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isPersistent = true
                                }
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            }
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPressed = false
                        }
                        timer?.invalidate()
                        if !isPersistent {
                            onRecordingChange(false)
                        }
                        isPersistent = false
                    }
            )
    }
}

#Preview {
    ZStack {
        Color.black
        AuraView(
            onTap: { print("Tapped") },
            onRecordingChange: { isRecording in 
                print(isRecording ? "Recording started" : "Recording stopped")
            }
        )
    }
}
