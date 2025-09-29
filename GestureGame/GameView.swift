import SwiftUI

struct GameView: View {
    @State private var playerPosition: CGPoint = CGPoint(x: 200, y: 600) // ✅ Player starts near the bottom
    @State private var score = 0
    @State private var gameOver = false
    @State private var enemies: [Enemy] = [] // ✅ Array to store enemy objects
    @State private var gameTimer: Timer?
    @State private var scoreTimer: Timer?

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // ✅ Game Background
            
            /// **Game Title**
            Text("Bullet Storm Game!")
                .font(.largeTitle)
                .foregroundColor(.white)
                .offset(y: -350)
                .zIndex(2)

            /// **Player Circle**
            Circle()
                .fill(Color.blue)
                .frame(width: 40, height: 40)
                .position(playerPosition)
                .gesture(dragGesture) // ✅ Enables dragging to dodge
                .gesture(tapGesture) // ✅ Tap to jump
                .gesture(longPressGesture) // ✅ Long press to jump down

            /// **Enemies**
            ForEach(enemies) { enemy in
                Circle()
                    .fill(Color.red)
                    .frame(width: enemy.size, height: enemy.size)
                    .position(enemy.position)
            }

            /// **Score Display (Time Survived)**
            Text("Time Survived: \(score) sec")
                .font(.title)
                .foregroundColor(.white)
                .offset(y: -300)

            /// **Game Over Message**
            if gameOver {
                VStack {
                    Text("Game Over!")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Button(action: resetGame) {
                        Text("Restart")
                            .font(.title2)
                            .bold()
                            .padding()
                            .frame(width: 200)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .offset(y: -200)
            }
        }
        .onAppear {
            startGame()
        }
    }

    // MARK: - Gestures
    
    /// **Tapping moves the player up!**
    var tapGesture: some Gesture {
        TapGesture()
            .onEnded {
                if playerPosition.y > 100 {
                    withAnimation(.spring()) {
                        playerPosition.y -= 50
                    }
                }
            }
    }
    
    /// **Long press moves the player down!**
    var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .onEnded { _ in
                if playerPosition.y < 700 {
                    withAnimation(.spring()) {
                        playerPosition.y += 50
                    }
                }
            }
    }
    
    /// **Dragging moves the player left or right**
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(.easeInOut(duration: 0.1)) {
                    playerPosition.x = value.location.x // ✅ Moves only left/right
                }
            }
    }

    // MARK: - Game Logic

    /// **Start Game Loop**
    func startGame() {
        gameTimer?.invalidate()
        scoreTimer?.invalidate()

        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            spawnEnemy()
            moveEnemies()
            checkCollision()
        }
        
        scoreTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !gameOver {
                score += 1
            }
        }
    }

    /// **Spawn a Random Enemy Continuously**
    func spawnEnemy() {
        let randomX = CGFloat.random(in: 50...350) // ✅ Random X position
        let randomSize = CGFloat.random(in: 20...30) // ✅ Random size for difficulty
        let newEnemy = Enemy(position: CGPoint(x: randomX, y: 0), size: randomSize)

        enemies.append(newEnemy)
    }

    /// **Move Enemies Downward Continuously**
    func moveEnemies() {
        for index in enemies.indices {
            withAnimation(.linear(duration: 0.3)) {
                enemies[index].position.y += 40 // ✅ Moves downward smoothly
            }
        }
        
        
        enemies.removeAll { $0.position.y > 750 } // ✅ Remove enemies off-screen
    }

    /// **Check for Collisions**
    func checkCollision() {
        for enemy in enemies {
            let distance = sqrt(pow(playerPosition.x - enemy.position.x, 2) +
                                pow(playerPosition.y - enemy.position.y, 2))

            if distance < (enemy.size / 2 + 25) { // ✅ If enemy size overlaps player
                gameOver = true
                gameTimer?.invalidate() // ✅ Stop game loop
                scoreTimer?.invalidate()
            }
        }
    }

    /// **Reset the Game**
    func resetGame() {
        playerPosition = CGPoint(x: 200, y: 600)
        score = 0
        enemies.removeAll()
        gameOver = false
        startGame()
    }
}

/// **Enemy Struct**
struct Enemy: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
}

#Preview {
    GameView()
}
