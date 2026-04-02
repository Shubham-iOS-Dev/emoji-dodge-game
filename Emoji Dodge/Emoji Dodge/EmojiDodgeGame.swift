//
//  EmojiDodgeGame.swift
//  Emoji Dodge
//
//  Created by Shubham on 02/04/26.
//


import SwiftUI
internal import Combine

struct EmojiDodgeGame: View {
    // 1. Difficulty Definition
    enum Difficulty: String, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        
        var baseSpeed: CGFloat {
            switch self { case .easy: return 3; case .medium: return 6; case .hard: return 9 }
        }
        
        var spawnRate: Int {
            switch self { case .easy: return 40; case .medium: return 25; case .hard: return 15 }
        }
    }

    enum GameState { case home, playing, gameOver, won }
    
    // Game State
    @State private var currentState: GameState = .home
    @State private var selectedDifficulty: Difficulty = .medium
    
    // Game Constants
    let playerSize: CGFloat = 60
    let emojiSize: CGFloat = 40
    let gameTimer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    let winConditionTime: TimeInterval = 60
    
    // Play State
    @State private var playerX: CGFloat = UIScreen.main.bounds.width / 2
    @State private var emojis: [EmojiObstacle] = []
    @State private var score = 0
    @State private var spawnCounter = 0
    @State private var startTime = Date()
    @State private var timeElapsed: TimeInterval = 0
    
    struct EmojiObstacle: Identifiable {
        let id = UUID(); var x: CGFloat; var y: CGFloat; let symbol: String
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                switch currentState {
                case .home:
                    homeScreen(in: geometry)
                case .playing:
                    gamePlayView(in: geometry)
                case .gameOver:
                    gameOverView(in: geometry)
                case .won:
                    winView(in: geometry)
                }
            }
            .onReceive(gameTimer) { _ in
                if currentState == .playing { updateGame(in: geometry) }
            }
        }
    }
    
    // MARK: - Updated Home Screen with Difficulty
    func homeScreen(in geo: GeometryProxy) -> some View {
        VStack(spacing: 25) {
            Text("👾 Emoji Dodge")
                .font(.system(size: 45, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                Text("Select Difficulty")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 15) {
                    ForEach(Difficulty.allCases, id: \.self) { diff in
                        Button(diff.rawValue) {
                            selectedDifficulty = diff
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(selectedDifficulty == diff ? Color.blue : Color.white.opacity(0.1))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: selectedDifficulty == diff ? 2 : 0)
                        )
                    }
                }
            }
            .padding(.bottom, 20)
            
            Button(action: {
                resetGame(in: geo)
                currentState = .playing
            }) {
                Text("START GAME")
                    .font(.title2).bold()
                    .foregroundColor(.white)
                    .frame(width: 220, height: 60)
                    .background(Color.green)
                    .cornerRadius(30)
            }
        }
    }

    // MARK: - Updated Game Logic
    func updateGame(in geo: GeometryProxy) {
        timeElapsed = Date().timeIntervalSince(startTime)
        if timeElapsed >= winConditionTime { currentState = .won; return }
        
        // Use selectedDifficulty for speed and scaling
        for i in emojis.indices {
            let speedScale = CGFloat(score / 15)
            emojis[i].y += selectedDifficulty.baseSpeed + speedScale
        }
        
        let countBefore = emojis.count
        emojis.removeAll { $0.y > geo.size.height + 50 }
        score += (countBefore - emojis.count)
        
        // Use selectedDifficulty for spawn rate
        spawnCounter += 1
        if spawnCounter >= selectedDifficulty.spawnRate {
            let randomX = CGFloat.random(in: 20...(geo.size.width - 20))
            emojis.append(EmojiObstacle(x: randomX, y: -50, symbol: ["🔥", "💣", "👾", "🌵", "☄️"].randomElement()!))
            spawnCounter = 0
        }
        
        checkCollisions(geo: geo)
    }

    // (Remaining View functions: gamePlayView, winView, gameOverView, etc., stay the same as previous)
    
    func gamePlayView(in geo: GeometryProxy) -> some View {
        ZStack {
            VStack {
                Text("\(Int(winConditionTime - timeElapsed))s")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(.yellow)
                Text("Difficulty: \(selectedDifficulty.rawValue)")
                    .foregroundColor(.gray)
                Text("Score: \(score)")
                    .foregroundColor(.white)
            }
            .position(x: geo.size.width / 2, y: 80)
            
            ForEach(emojis) { emoji in
                Text(emoji.symbol).font(.system(size: emojiSize)).position(x: emoji.x, y: emoji.y)
            }
            
            Text("👤")
                .font(.system(size: playerSize))
                .position(x: playerX, y: geo.size.height - 100)
                .gesture(DragGesture().onChanged { v in playerX = min(max(v.location.x, playerSize/2), geo.size.width - playerSize/2) })
        }
    }

    func winView(in geo: GeometryProxy) -> some View { overlay(title: "🏆 WON! 🏆", msg: "Mastered \(selectedDifficulty.rawValue)!", btn: "Play Again", clr: .green, geo: geo) }
    func gameOverView(in geo: GeometryProxy) -> some View { overlay(title: "GAME OVER", msg: "Score: \(score)", btn: "Try Again", clr: .red, geo: geo) }

    func overlay(title: String, msg: String, btn: String, clr: Color, geo: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            Text(title).font(.largeTitle).fontWeight(.black).foregroundColor(clr)
            Text(msg).font(.title3).foregroundColor(.white)
            Button(btn) { resetGame(in: geo); currentState = .playing }.buttonStyle(.borderedProminent).tint(clr)
            Button("Home") { currentState = .home }.foregroundColor(.gray)
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.black.opacity(0.9))
    }

    func checkCollisions(geo: GeometryProxy) {
        let playerY = geo.size.height - 100
        for emoji in emojis {
            if sqrt(pow(emoji.x - playerX, 2) + pow(emoji.y - playerY, 2)) < (playerSize / 1.5) { currentState = .gameOver }
        }
    }

    func resetGame(in geo: GeometryProxy) {
        playerX = geo.size.width / 2; emojis = []; score = 0; spawnCounter = 0; startTime = Date(); timeElapsed = 0
    }
}
