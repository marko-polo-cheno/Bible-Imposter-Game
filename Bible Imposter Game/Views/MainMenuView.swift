import SwiftUI

struct MainMenuView: View {
    @ObservedObject var vm: GameViewModel
    @State private var newPlayerName: String = ""
    
    var body: some View {
        VStack {
            Text("Bible Imposter")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Picker("Difficulty", selection: $vm.selectedDifficulty) {
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    Text(difficulty.rawValue).tag(difficulty)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            HStack {
                TextField("Add Player Name", text: $newPlayerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: addPlayer) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
                .disabled(newPlayerName.isEmpty)
                .padding(.trailing)
            }
            
            HStack {
                Text("Players")
                    .font(.headline)
                Spacer()
                if !vm.roster.isEmpty {
                    Button(action: {
                        vm.removeAllPlayers()
                    }) {
                        Text("Clear All")
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                }
            }
            .padding(.horizontal)
            
            List {
                Section(footer: Text("Swipe left to remove a player")) {
                    ForEach(vm.roster) { player in
                        Text(player.name)
                    }
                    .onDelete(perform: vm.removePlayer)
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            Button(action: {
                vm.startGame()
            }) {
                Text("Start Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(vm.roster.count >= 3 ? Color.blue : Color.gray)
                    .cornerRadius(10)
            }
            .disabled(vm.roster.count < 3)
            .padding()
            
            if vm.roster.count < 3 {
                Text("Need at least 3 players to start.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom)
            }
            
            Link("tjc.org", destination: URL(string: "https://tjc.org/")!)
                .padding(.bottom)
            
            Text("p.s. please email mark.chen@tjc.org if something seems off")
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.bottom)
        }
        .padding(.top)
        .alert(isPresented: $vm.showError) {
            Alert(
                title: Text("Error"),
                message: Text(vm.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func addPlayer() {
        guard !newPlayerName.isEmpty else { return }
        vm.addPlayer(name: newPlayerName)
        newPlayerName = ""
    }
}

