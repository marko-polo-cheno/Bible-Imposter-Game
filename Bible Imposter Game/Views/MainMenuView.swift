import SwiftUI

struct MainMenuView: View {
    @ObservedObject var vm: GameViewModel
    @State private var newPlayerName: String = ""
    @State private var showSettings: Bool = false
    @FocusState private var isKeyboardVisible: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title and settings
            HStack {
                Spacer()
                Text("Bible Imposter")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Current settings summary
            HStack {
                Text(vm.selectedDifficulty.rawValue)
                Text("•")
                Text(vm.selectedLanguage.rawValue)
                if vm.showHintForImposter {
                    Text("•")
                    Text("Hints On")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.bottom, 24)
            
            // Start Game button - always visible at top
            Button(action: { vm.startGame() }) {
                Text("Start Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(vm.roster.count >= 3 ? Color.blue : Color.gray)
                    .cornerRadius(10)
            }
            .disabled(vm.roster.count < 3)
            .padding(.horizontal)
            
            if vm.roster.count < 3 {
                Text("Need at least 3 players to start.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
            
            // Add player section
            HStack {
                TextField("Add Player Name", text: $newPlayerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isKeyboardVisible)
                    .padding(.horizontal)
                    .onSubmit { addPlayer() }
                
                Button(action: addPlayer) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
                .disabled(newPlayerName.isEmpty)
                .padding(.trailing)
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
            // Player list
            List {
                Section(footer: footerView) {
                    ForEach(vm.roster) { player in
                        Text(player.name)
                    }
                    .onDelete(perform: vm.removePlayer)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(vm: vm)
        }
        .alert(isPresented: $vm.showError) {
            Alert(
                title: Text("Error"),
                message: Text(vm.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private var footerView: some View {
        HStack {
            Text("Swipe left to remove a player")
            Spacer()
            if !vm.roster.isEmpty {
                Button("Clear All") {
                    vm.removeAllPlayers()
                }
                .font(.footnote)
                .foregroundColor(.red)
            }
        }
    }
    
    private func addPlayer() {
        guard !newPlayerName.isEmpty else { return }
        vm.addPlayer(name: newPlayerName)
        newPlayerName = ""
    }
}
