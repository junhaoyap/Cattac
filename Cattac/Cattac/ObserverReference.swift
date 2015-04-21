class ObserverReference {
    private let unregisterAction: (() -> Void)?
    
    init(unregister: (() -> Void)?) {
        unregisterAction = unregister
    }
    
    func unregister() {
        unregisterAction()
    }
}
