//
//  ViewController.swift
//  project7-9
//
//  Created by Karina Dolmatova on 29.10.2024.
//

import UIKit

class ViewController: UIViewController {
    var allWords = [String]()
    var currentWord: String?
    var guessedLetters: [Character] = []
    var livesLeft = 10 {
        didSet {
            scoreLabel.text = "\(livesLeft) lives left"
        }
    }
    
    @IBOutlet weak var guessedWordLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New game", style: .plain, target: self, action: #selector(restartGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWordsString = try? String(contentsOf: startWordsURL, encoding: .utf8) {
                allWords = startWordsString.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    
    @objc func restartGame() {
        let ac = UIAlertController(title: "New game", message: nil, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.livesLeft = 10
            self?.startGame()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func startGame() {
        currentWord = allWords.randomElement() ?? "silkworm"
        if let currentWord = currentWord {
            guessedLetters = Array(repeating: "?", count: currentWord.count)
            print ("Current word: \(currentWord)")
            livesLeft = 10
            updateUI()
        }
    }
    
    func updateUI() {
        let displayedWord = String(guessedLetters)
        
        guessedWordLabel.text = displayedWord
        scoreLabel.text = "\(livesLeft) lives left"
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer: answer.lowercased())
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(answer: String) {
        guard let letter = answer.first, letter.isLetter else {
            showAlert(title: "It's not a letter", message: "Please enter a single letter.")
            return
        }
        
        guard !guessedLetters.contains(letter) else {
            showAlert(title: "Already guessed", message: "You've already guessed that letter.")
            return
        }
        
        guard let currentWord = currentWord else { return }
        
        if !currentWord.contains(letter) {
            livesLeft -= 1
            if livesLeft == 0 {
                gameOver()
            } else {
                showAlert(title: "Wrong!", message: "The word doesn't contain that letter. Try again!")
            }
            return
        }
        
        for (index, char) in currentWord.enumerated() {
            if char == letter {
                guessedLetters[index] = letter
            }
        }
        
        if String(guessedLetters) == currentWord {
            showAlert(title: "Congratulations!", message: "You guessed the word! Starting a new word.") {
                self.startGame()
            }
        } else {
            updateUI()
        }
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(ac, animated: true)
    }
    
    func gameOver() {
        let ac = UIAlertController(title: "Game Over", message: "You ran out of lives", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Restart", style: .default, handler: { _ in
            self.startGame()
        }))
        present(ac, animated: true)
    }
}
