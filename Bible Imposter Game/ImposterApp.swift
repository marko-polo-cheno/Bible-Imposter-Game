import SwiftUI

@main
struct ImposterApp: App {
    @StateObject var vm = GameViewModel()
    
    var body: some Scene {
        WindowGroup {
            if vm.gameStatus == .setup {
                MainMenuView(vm: vm)
            } else {
                GameSessionView(vm: vm)
            }
        }
    }
}

