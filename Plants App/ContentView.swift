//
//  ContentView.swift
//  Plants App
//
//  Created by Fajer alQahtani on 28/04/1447 AH.
//

import SwiftUI
import SwiftData

//MARK: -DARK MODE
struct DarkMode: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
            .modelContainer(for: Plant.self, inMemory: true)
    }
}

//MARK: -Coding
struct ContentView: View {
    @State private var isShowingReminder = false
    @AppStorage("hasAddedFirstPlant") private var hasAddedFirstPlant: Bool = false

    // Query to know if we have any plants
    @Query private var plants: [Plant]

    // Local sheet state
    @State private var plantName: String = ""
    @State private var room: String = "Bedroom"
    @State private var light: String = "Full sun"
    @State private var wateringDays: String = "Every day"
    @State private var waterAmount: String = "20–50 ml"

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if plants.isEmpty && hasAddedFirstPlant == false {
                // Empty state
                VStack {
                    Text("My Plants 🌱")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .font(.title)
                        .fontWeight(.heavy)
                        .frame(maxWidth: .infinity,  alignment: .topLeading)
                        .padding(.top, 0)

                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 327 - 60 ,height: 1)
                        .padding(.trailing, 60)

                    Divider()

                    Image("Plant")
                        .resizable()
                        .padding()
                        .scaledToFit()
                        .frame(width:280 ,height: 245)
                        .padding(.top, 20)

                    Text("Start Your Plant Journey!")
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .font(.title2)

                    Text("Now all your plants will be in one place and we will help you take care of them  :)🪴")
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)

                    Spacer()

                    Button(action: { isShowingReminder = true }) {
                        Text("Set Plant Reminder")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 280, height: 44)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.34, green: 0.82, blue: 0.54),
                                        Color(red: 0.22, green: 0.79, blue: 0.54)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                    }
                    .sheet(isPresented: $isShowingReminder) {
                        SetReminder()
                            .onDisappear {
                                // If a plant was added, the query will update; set the flag so empty state won't return
                                if !plants.isEmpty { hasAddedFirstPlant = true }
                            }
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                            .presentationCornerRadius(32)
                            .interactiveDismissDisabled(false)
                    }
                    .padding(.bottom, 40)
                }
                .frame(width: 327, alignment: .top)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding()
            } else {
                PlantsListView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Plant.self, inMemory: true)
}
