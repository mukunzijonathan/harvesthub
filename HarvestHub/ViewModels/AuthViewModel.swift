import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: User?          // nil means nobody is signed in
    @Published var errorMessage: String?
    @Published var isWorking = false

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        user = Auth.auth().currentUser
        // Firebase tells us whenever someone signs in or out.
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }

    func signUp(email: String, password: String) {
        start()
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] _, error in
            self?.finish(error)
        }
    }

    func signIn(email: String, password: String) {
        start()
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            self?.finish(error)
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func start() {
        errorMessage = nil
        isWorking = true
    }

    private func finish(_ error: Error?) {
        isWorking = false
        errorMessage = error?.localizedDescription
    }
}
