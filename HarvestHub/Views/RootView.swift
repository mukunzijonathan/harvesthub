import SwiftUI

struct RootView: View {
    @StateObject private var auth = AuthViewModel()

    var body: some View {
        if auth.user != nil {
            FarmerListView()               // the app, for signed-in officers
                .environmentObject(auth)   // so the list can show the email and sign out
        } else {
            LoginView(auth: auth)          // the door, for everyone else
        }
    }
}
