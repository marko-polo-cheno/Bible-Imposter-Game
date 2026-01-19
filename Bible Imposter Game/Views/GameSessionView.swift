import SwiftUI

struct GameSessionView: View {
    @ObservedObject var vm: GameViewModel
    @State private var isRevealed: Bool = false
    @State private var displayedRole: String? = nil
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack {
                if vm.gameStatus == .finished {
                    finishedView
                } else {
                    gamePlayView
                }
            }
            .padding()
        }
    }
    
    var gamePlayView: some View {
        let currentPlayer = vm.roster[vm.currentPlayerIndex]
        
        return VStack(spacing: 30) {
            Text("Pass the phone to:")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text(currentPlayer.name)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Card Interaction
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(isRevealed ? Color.blue : Color.gray)
                    .shadow(radius: 10)
                    .frame(height: 300)
                
                if isRevealed {
                    VStack {
                        Text("Your Role:")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(displayedRole ?? "")
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    Text("Hold to Reveal")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: 0.5, pressing: { pressing in
                if pressing {
                    displayedRole = vm.getRole(for: currentPlayer.id)
                } else {
                    displayedRole = nil
                }
                withAnimation {
                    isRevealed = pressing
                }
            }) {}
            
            Spacer()
            
            Button(action: {
                // Clear state before moving to next player
                isRevealed = false
                displayedRole = nil
                vm.nextPlayer()
            }) {
                Text("Next Player")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.bottom)
        }
    }
    
    var finishedView: some View {
        VStack(spacing: 20) {
            Text("All players are ready!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("The starting player is:")
                .font(.title2)
            
            if let startID = vm.startingPlayerID,
               let starter = vm.roster.first(where: { $0.id == startID }) {
                Text(starter.name)
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Button(action: {
                vm.resetGame()
            }) {
                Text("Back to Menu")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}
