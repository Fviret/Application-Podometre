import CoreLocation
import Combine
import Foundation

/// Gestionnaire de localisation — demande une position unique à la précision kilomètre.
/// Suffisant pour la météo ; évite une consommation GPS excessive.
///
/// Ne demande **jamais** l'autorisation de lui-même : l'appelant choisit le moment
/// (`requestAuthorizationIfNeeded()`), pour que le prompt système arrive dans son contexte
/// (slide d'onboarding sur les autorisations, ou carte « Météo près de chez vous »).
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    /// Statut d'autorisation courant ; `.notDetermined` tant que le prompt n'a pas été présenté.
    @Published private(set) var authorizationStatus: CLAuthorizationStatus

    private let manager = CLLocationManager()
    /// Appelants en attente de la réponse au prompt (voir `requestAuthorizationIfNeeded()`).
    private var authorizationContinuations: [CheckedContinuation<Void, Never>] = []

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    /// `true` si l'accès à la position est accordé (en cours d'utilisation ou toujours).
    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    /// Présente le prompt système si l'utilisateur n'a pas encore choisi, et rend la main une
    /// fois qu'il a répondu. Retourne immédiatement si le choix a déjà été fait.
    ///
    /// Ne reste jamais bloquée : si les services de localisation sont désactivés dans iOS (aucune
    /// réponse n'arrivera), elle rend la main tout de suite sans présenter de prompt ; sinon elle
    /// libère l'appelant après `timeout` même sans réponse (le prompt reste à l'écran).
    func requestAuthorizationIfNeeded(timeout: Duration = .seconds(45)) async {
        guard authorizationStatus == .notDetermined else { return }
        // Appel potentiellement lent : hors du fil principal.
        let servicesEnabled = await Task.detached { CLLocationManager.locationServicesEnabled() }.value
        guard servicesEnabled else { return }

        await withCheckedContinuation { continuation in
            authorizationContinuations.append(continuation)
            manager.requestWhenInUseAuthorization()
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: timeout)
                self?.resumeAuthorizationWaiters()
            }
        }
    }

    /// Libère tous les appelants en attente de la réponse au prompt.
    private func resumeAuthorizationWaiters() {
        let waiting = authorizationContinuations
        authorizationContinuations.removeAll()
        waiting.forEach { $0.resume() }
    }

    /// Demande une position unique. Sans effet tant que l'accès n'est pas accordé.
    func requestLocation() {
        guard isAuthorized else { return }
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if isAuthorized {
            manager.requestLocation()
        }
        if authorizationStatus != .notDetermined {
            resumeAuthorizationWaiters()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
