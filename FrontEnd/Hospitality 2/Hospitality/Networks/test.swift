//import SwiftUI
//import Foundation
//
//struct SignUpView: View {
//    @StateObject private var viewModel = AuthViewModel()
//    @State private var email = ""
//    @State private var password = ""
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Sign Up")
//                .font(.largeTitle)
//                .bold()
//
//            TextField("Email", text: $email)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .autocapitalization(.none)
//                .keyboardType(.emailAddress)
//                .padding(.horizontal)
//
//            Button(action: {
//                print("Button Pressed")
//                print("Email: \(email)")
//                viewModel.sendOTP(email: email, password: password, userType: "Patient")
//            }) {
//                Text("Send OTP")
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.blue)
//                    .cornerRadius(10)
//            }
//            .padding(.horizontal)
//
//            if !viewModel.otpMessage.isEmpty {
//                Text(viewModel.otpMessage)
//                    .foregroundColor(.green)
//                    .padding(.top)
//            }
//
//            Spacer()
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    SignUpView()
//}
