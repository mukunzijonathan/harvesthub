import SwiftUI

struct LoginView: View {
    @ObservedObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    private var canSubmit: Bool {
        !email.isEmpty && password.count >= 6 && !auth.isWorking
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("🌾").font(.system(size: 64))
            Text("HarvestHub").font(.largeTitle).bold()
            Text("Sign in to manage your cooperative's farmers.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                SecureField("Password (at least 6 characters)", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
            }
            .padding(.top, 8)

            if let error = auth.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button {
                auth.signIn(email: email, password: password)
            } label: {
                Group {
                    if auth.isWorking {
                        ProgressView().tint(.white)
                    } else {
                        Text("Sign In").bold()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!canSubmit)

            Button("Create an account") {
                auth.signUp(email: email, password: password)
            }
            .disabled(!canSubmit)

            Spacer()
            Spacer()
        }
        .padding(24)
        .tint(.green)
    }
}
