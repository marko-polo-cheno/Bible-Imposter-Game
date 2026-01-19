import SwiftUI

struct SettingsView: View {
    @ObservedObject var vm: GameViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Difficulty")) {
                    Picker("Difficulty", selection: $vm.selectedDifficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Language")) {
                    Picker("Language", selection: $vm.selectedLanguage) {
                        ForEach(Language.allCases, id: \.self) { language in
                            Text(language.rawValue).tag(language)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Imposter Options"), footer: Text("When enabled, the imposter sees a category hint (e.g., \"person\", \"place\", \"event\") to help them blend in.")) {
                    Toggle("Show Hint for Imposter", isOn: $vm.showHintForImposter)
                }
                
                Section {
                    Link(destination: URL(string: "https://tjc.org/")!) {
                        HStack {
                            Text("tjc.org")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Text("p.s. please email mark.chen@tjc.org if something seems off")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
