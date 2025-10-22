//
//  ContentView.swift
//  Math Buddy
//
//  Created by Subhajit Sarkar on 22/10/25.
//

import SwiftUI

struct Question {
    let num1: Int
    let num2: Int
    let text: String
    let answer: Int
    
    init(num1: Int, num2: Int) {
        self.num1 = num1
        self.num2 = num2
        self.text = "\(num1) × \(num2)"
        self.answer = num1 * num2
    }
}

enum GameState {
    case setup
    case playing
    case results
}

struct ContentView: View {
    @State private var gameState = GameState.setup
    @State private var maxTable = 5
    @State private var questionCount = 10
    @State private var questions: [Question] = []
    @State private var currentIndex = 0
    @State private var score = 0
    
    var body: some View {
        ZStack {
            switch gameState {
            case .setup:
                SetupView(maxTable: $maxTable, questionCount: $questionCount) {
                    startGame()
                }
            case .playing:
                GameView(
                    questions: questions,
                    currentIndex: $currentIndex,
                    score: $score
                ) {
                    gameState = .results
                }
            case .results:
                ResultsView(score: score, total: questions.count) {
                    gameState = .setup
                }
            }
        }
    }
    
    func startGame() {
        questions = (0..<questionCount).map { _ in
            Question(num1: Int.random(in: 2...maxTable), num2: Int.random(in: 2...maxTable))
        }
        currentIndex = 0
        score = 0
        gameState = .playing
    }
}

struct SetupView: View {
    @Binding var maxTable: Int
    @Binding var questionCount: Int
    let onStart: () -> Void
    
    let tableOptions = [2, 5, 10]
    let countOptions = [5, 10, 20]
    
    var body: some View {
        LinearGradient(colors: [.blue, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 40) {
                    VStack(spacing: 10) {
                        Text("MathBuddy")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.white)
                        Text("Train your brain with multiplication!")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    VStack(spacing: 25) {
                        VStack {
                            Text("Practice up to:")
                                .foregroundColor(.white)
                            HStack {
                                ForEach(tableOptions, id: \.self) { num in
                                    Button("\(num)") {
                                        maxTable = num
                                    }
                                    .font(.title3)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(maxTable == num ? Color.blue : Color.white.opacity(0.2))
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                }
                            }
                        }
                        
                        VStack {
                            Text("Number of Questions:")
                                .foregroundColor(.white)
                            HStack {
                                ForEach(countOptions, id: \.self) { num in
                                    Button("\(num)") {
                                        questionCount = num
                                    }
                                    .font(.title3)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(questionCount == num ? Color.cyan : Color.white.opacity(0.2))
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                }
                            }
                        }
                        
                        Button("Start Game ▶") {
                            onStart()
                        }
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15)
                        .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                }
                .padding()
            )
    }
}

struct GameView: View {
    let questions: [Question]
    @Binding var currentIndex: Int
    @Binding var score: Int
    let onGameEnd: () -> Void
    
    @State private var userAnswer = ""
    @State private var feedback = ""
    
    var current: Question { questions[currentIndex] }
    
    var body: some View {
        LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 40) {
                    HStack {
                        Text("Q \(currentIndex + 1)/\(questions.count)")
                        Spacer()
                        Text("⭐ \(score)")
                    }
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Text(current.text)
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                    
                    TextField("?", text: $userAnswer)
                        .font(.system(size: 48, weight: .bold))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .frame(maxWidth: 200)
                    
                    if !feedback.isEmpty {
                        Text(feedback)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    } else {
                        Button("Check ✓") {
                            checkAnswer()
                        }
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(userAnswer.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(15)
                        .foregroundColor(.white)
                        .disabled(userAnswer.isEmpty)
                    }
                    
                    Spacer()
                }
                .padding()
            )
    }
    
    func checkAnswer() {
        if Int(userAnswer) == current.answer {
            feedback = "✅ Correct!"
            score += 1
        } else {
            feedback = "❌ Answer: \(current.answer)"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if currentIndex < questions.count - 1 {
                currentIndex += 1
                userAnswer = ""
                feedback = ""
            } else {
                onGameEnd()
            }
        }
    }
}

struct ResultsView: View {
    let score: Int
    let total: Int
    let onPlayAgain: () -> Void
    
    var percentage: Int {
        Int((Double(score) / Double(total)) * 100)
    }
    
    var message: String {
        switch percentage {
        case 100: "Perfect!"
        case 80...99: "Awesome!"
        case 60...79: "Good Try!"
        default: "Keep Practicing!"
        }
    }
    
    var body: some View {
        LinearGradient(colors: [.black, .blue], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 40) {
                    Text("🏆")
                        .font(.system(size: 80))
                    
                    Text(message)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(score)/\(total)")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.cyan)
                    
                    Button("Play Again 🔁") {
                        onPlayAgain()
                    }
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(15)
                    .foregroundColor(.white)
                }
                .padding()
            )
    }
}

#Preview {
    ContentView()
}
