//
//  ContentView.swift
//  TictacGO
//
//  Created by Muhammad Farkhanudin on 19/05/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var game = TicTacToeGame()
    
    var body: some View {
        VStack {
            Text("TicTac GO")
                .font(.title)
                .padding()
                .offset(y: -14)
            
            HStack {
                ScoreView(player: "Player 1", score: game.scorePlayer1)
                ScoreView(player: "Player 2", score: game.scorePlayer2)
            }
            .padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach(0..<9) { index in
                    Button(action: {
                        game.makeMove(at: index)
                    }) {
                        Text(game.board[index])
                            .font(.largeTitle)
                            .frame(width: 80, height: 80)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!game.isMoveValid(at: index) || !game.gameActive)
                }
            }
            .padding()
            
            Text(game.status)
                .font(.title)
                .padding()
            
            HStack {
                Button("Reset Score") {
                    game.resetScore()
                }
                .font(.title)
                .padding()
                
                Button("Next Game") {
                    game.restart()
                }
                .font(.title)
                .padding()
            }
        }
        .alert(isPresented: $game.showPlayerTurnAlert) {
            Alert(
                title: Text("Player \(game.currentPlayer)"),
                message: Text("Your turn to play!"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct ScoreView: View {
    let player: String
    let score: Int
    
    var body: some View {
        VStack {
            Text(player)
                .font(.title2)
            Text("\(score)")
                .font(.title)
        }
        .padding()
    }
}

class TicTacToeGame: ObservableObject {
    @Published private(set) var currentPlayer: String = "X"
    @Published private(set) var board: [String] = Array(repeating: "", count: 9)
    @Published private(set) var gameActive: Bool = true
    @Published private(set) var status: String = ""
    @Published var scorePlayer1: Int = 0
    @Published var scorePlayer2: Int = 0
    @Published var showPlayerTurnAlert: Bool = false
    
    func makeMove(at index: Int) {
        if gameActive && isMoveValid(at: index) {
            board[index] = currentPlayer
            
            if isWinningMove() {
                status = "Player \(currentPlayer) wins!"
                gameActive = false
                
                if currentPlayer == "X" {
                    scorePlayer1 += 1
                } else {
                    scorePlayer2 += 1
                }
            } else if isBoardFull() {
                status = "Game is tied!"
                gameActive = false
            } else {
                currentPlayer = currentPlayer == "X" ? "O" : "X"
            }
            
            showPlayerTurnAlert = true
        }
    }
    
    func isMoveValid(at index: Int) -> Bool {
        return board[index].isEmpty
    }
    
    private func isWinningMove() -> Bool {
        let winningMoves: [[Int]] = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8], // horizontal
            [0, 3, 6], [1, 4, 7], [2, 5, 8], // vertical
            [0, 4, 8], [2, 4, 6] // diagonal
        ]
        
        for moves in winningMoves {
            if board[moves[0]] == currentPlayer && board[moves[1]] == currentPlayer && board[moves[2]] == currentPlayer {
                return true
            }
        }
        
        return false
    }
    
    private func isBoardFull() -> Bool {
        return !board.contains("")
    }
    
    func restart() {
        currentPlayer = "X"
        board = Array(repeating: "", count: 9)
        gameActive = true
        status = ""
        showPlayerTurnAlert = false
    }
    
    func resetScore() {
        scorePlayer1 = 0
        scorePlayer2 = 0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
