import SwiftUI

struct PaymentSuccessView: View {
    // MARK: - Properties
    @Environment(\.presentationMode) var presentationMode
    let transactionId: String
    var onDone: (() -> Void)? // Add completion handler
    
    // Static amount
    let staticAmount: Double = 350.0
    
    // Animation states
    @State private var showCircle = false
    @State private var showCheckmark = false
    @State private var showDetails = false
    @State private var showConfetti = false
    
    // Confetti properties
    let confettiColors: [Color] = [.blue, .red, .green, .yellow, .pink, .purple, .orange]
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "F0F8FF"), Color(hex: "E8F5FF")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Confetti
            ZStack {
                ForEach(0..<100, id: \.self) { index in
                    ConfettiPiece(
                        color: confettiColors[index % confettiColors.count],
                        size: CGFloat.random(in: 5...15),
                        position: CGPoint(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: -20  // start off-screen at top
                        ),
                        isActive: $showConfetti
                    )
                }
            }
            
            VStack(spacing: 25) {
                // Success animation
                ZStack {
                    // Green circle background
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: showCircle ? 220 : 0, height: showCircle ? 220 : 0)
                        .animation(.easeInOut(duration: 0.6), value: showCircle)
                    
                    // Green circle
                    Circle()
                        .fill(Color.green)
                        .frame(width: showCircle ? 180 : 0, height: showCircle ? 180 : 0)
                        .animation(.easeInOut(duration: 0.6).delay(0.1), value: showCircle)
                    
                    // Checkmark
                    Image(systemName: "checkmark")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(showCheckmark ? 1 : 0)
                        .scaleEffect(showCheckmark ? 1 : 0.5)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.4), value: showCheckmark)
                }
                .padding(.top, 40)
                
                // Success message
                Text("Payment Successful!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "333333"))
                    .opacity(showDetails ? 1 : 0)
                    .animation(.easeInOut.delay(0.8), value: showDetails)
                
                // Payment details
                VStack(spacing: 16) {
                    // Amount - Always show 350.00
                    HStack {
                        Text("Amount Paid:")
                            .font(.headline)
                            .foregroundColor(Color(hex: "666666"))
                        
                        Spacer()
                        
                        Text("₹\(String(format: "%.2f", staticAmount))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "333333"))
                    }
                    
                    Divider()
                    
                    // Transaction ID
                    HStack {
                        Text("Transaction ID:")
                            .font(.headline)
                            .foregroundColor(Color(hex: "666666"))
                        
                        Spacer()
                        
                        Text(transactionId)
                            .font(.body)
                            .foregroundColor(Color(hex: "333333"))
                    }
                    
                    Divider()
                    
                    // Date and time - shows current date and time
                    HStack {
                        Text("Date & Time:")
                            .font(.headline)
                            .foregroundColor(Color(hex: "666666"))
                        
                        Spacer()
                        
                        Text(formattedDate())
                            .font(.body)
                            .foregroundColor(Color(hex: "333333"))
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
                .opacity(showDetails ? 1 : 0)
                .offset(y: showDetails ? 0 : 30)
                .animation(.easeInOut.delay(1.0), value: showDetails)
                
                Spacer()
                
                // Done button
                Button(action: {
                    onDone?() // Call the completion handler
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("DONE")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "4A90E2"))
                        .cornerRadius(12)
                        .shadow(color: Color(hex: "B9614B").opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .opacity(showDetails ? 1 : 0)
                .offset(y: showDetails ? 0 : 30)
                .animation(.easeInOut.delay(1.2), value: showDetails)
            }
        }
        .onAppear {
            // Start animations sequentially
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showCircle = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                showCheckmark = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showDetails = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showConfetti = true
            }
        }
    }
    
    // MARK: - Helper Methods
    private func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: Date())
    }
}

// MARK: - Confetti Piece
struct ConfettiPiece: View {
    let color: Color
    let size: CGFloat
    let position: CGPoint
    @Binding var isActive: Bool
    
    @State private var rotation = Double.random(in: 0...360)
    @State private var offset: CGSize = .zero
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .position(x: position.x, y: position.y)
            .offset(offset)
            .opacity(isActive ? 1 : 0)
            .onAppear {
                if isActive {
                    startAnimation()
                }
            }
            .onChange(of: isActive) { newValue in
                if newValue {
                    startAnimation()
                }
            }
    }
    
    private func startAnimation() {
        let randomX = CGFloat.random(in: -100...100)
        // Move beyond the bottom of the screen
        let targetY = CGFloat.random(in: UIScreen.main.bounds.height + 50...UIScreen.main.bounds.height + 200)
        
        withAnimation(Animation.easeOut(duration: Double.random(in: 1.0...3.0))) {
            offset = CGSize(width: randomX, height: targetY)
            rotation = Double.random(in: 0...360)
        }
    }
}

// MARK: - Preview
struct PaymentSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentSuccessView(transactionId: "TXN12345678")
    }
}
