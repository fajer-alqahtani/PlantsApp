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

    // Query your plants so we can switch to the list once one exists
    @Query private var plants: [Plant]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)

            if plants.isEmpty {
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
                                ZStack {
                                    // Glass base
                                    Capsule(style: .continuous)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Capsule(style: .continuous)
                                                .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                                        )
                                        .shadow(color: .black.opacity(0.35), radius: 10, y: 5)

                                    // Existing gradient tint (slightly translucent)
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.34, green: 0.82, blue: 0.54).opacity(0.85),
                                            Color(red: 0.22, green: 0.79, blue: 0.54).opacity(0.85)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .clipShape(Capsule(style: .continuous))

                                    // Subtle inner highlight
                                    Capsule(style: .continuous)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.white.opacity(0.45), Color.white.opacity(0.05)],
                                                startPoint: .top, endPoint: .bottom
                                            ),
                                            lineWidth: 1
                                        )
                                        .blur(radius: 0.5)
                                }
                            )
                            .clipShape(Capsule())
                    }
                    .sheet(isPresented: $isShowingReminder) {
                        SetReminder()
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
                // Once at least one plant exists, show the list
                PlantsListView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Plant.self, inMemory: true)
}
