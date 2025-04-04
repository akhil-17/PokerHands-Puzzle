import Foundation

enum CardCondition: String, CaseIterable {
    case allHearts = "All ♥"
    case threeQueens = "3 Queens"
    case ascendingSequence = "Low to high"
    case fourSevens = "4 Sevens"
    case allFaceCards = "All face cards"
    case threeOfAKind = "3 of a kind"
    case flush = "Flush"
    case straight = "Straight"
    case pair = "Pair"
    case allSameSuit
    case descending
    case sumEquals
    case pokerHand
    case allSameRank
    case royalCourt
}

enum PokerHand {
    case pair
    case threeOfAKind
    case straight
    case flush
    case fullHouse
    case fourOfAKind
}

class CardGridViewModel: ObservableObject {
    @Published var cards: [[Card?]] = Array(repeating: Array(repeating: nil, count: 5), count: 5)
    @Published var emptyCardVariants: [[EmptyCardView.Variant]] = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
    @Published var rowConditions: [CardCondition] = []  // Conditions for both display and checking
    @Published var columnConditions: [CardCondition] = []
    private var initialCards: [[Card?]] = [] // Store the initial state
    
    // Make solutionCards a published property with default value
    @Published var solutionCards: [[Card?]] = Array(repeating: Array(repeating: nil, count: 5), count: 5)
    
    init(shuffleCards: Bool = true) {
        setupPrototypePuzzle()
        // Store the initial state before shuffling
        initialCards = cards
        solutionCards = initialCards
        if shuffleCards {
            shuffleInitialState()
        }
    }
    
    func resetToInitialState() {
        print("Resetting to initial state")
        cards = initialCards
    }
    
    func shuffleInitialState() {
        print("\n=== Starting shuffleInitialState ===")
        // Get all cards from the current state
        var allCards: [Card] = []
        for row in 0..<5 {
            for col in 0..<5 {
                if let card = cards[row][col] {
                    allCards.append(card)
                }
            }
        }
        print("Total cards to place: \(allCards.count)")
        
        // Try different placements to find one with minimal satisfied conditions
        let maxAttempts = 100
        var attempts = 0
        var bestLayout: [[Card?]]? = nil
        var minSatisfiedConditions = Int.max
        
        while attempts < maxAttempts {
            print("\nAttempt \(attempts + 1):")
            // Shuffle the cards
            allCards.shuffle()
            
            // Try to place cards
            let newLayout = placeCardsRandomly(allCards)
            
            // Count satisfied conditions
            var satisfiedConditions = 0
            var satisfiedRows: [Int] = []
            var satisfiedColumns: [Int] = []
            
            // Check all rows
            for row in 0..<5 {
                let rowCards = newLayout[row]
                let condition = rowConditions[row]
                if isConditionSatisfied(cards: rowCards, condition: condition) {
                    satisfiedConditions += 1
                    satisfiedRows.append(row)
                    print("Row \(row) satisfies condition: \(formatCondition(condition))")
                    print("Row cards: \(rowCards.compactMap { $0 }.map { "\($0.suit) \($0.rank)" })")
                }
            }
            
            // Check all columns
            for col in 0..<5 {
                let columnCards = getColumn(newLayout, col)
                let condition = columnConditions[col]
                if isConditionSatisfied(cards: columnCards, condition: condition) {
                    satisfiedConditions += 1
                    satisfiedColumns.append(col)
                    print("Column \(col) satisfies condition: \(formatCondition(condition))")
                    print("Column cards: \(columnCards.compactMap { $0 }.map { "\($0.suit) \($0.rank)" })")
                }
            }
            
            print("Total satisfied conditions: \(satisfiedConditions)")
            
            // Update best layout if we found one with fewer satisfied conditions
            if satisfiedConditions < minSatisfiedConditions {
                minSatisfiedConditions = satisfiedConditions
                bestLayout = newLayout
                print("New best layout found with \(satisfiedConditions) satisfied conditions!")
            }
            
            attempts += 1
        }
        
        // Use the best layout we found
        if let bestLayout = bestLayout {
            print("\nUsing best layout with \(minSatisfiedConditions) satisfied conditions")
            cards = bestLayout
        } else {
            print("\nNo valid layout found, falling back to random placement")
            cards = placeCardsRandomly(allCards)
        }
    }
    
    private func getColumn(_ layout: [[Card?]], _ col: Int) -> [Card?] {
        return [layout[0][col], layout[1][col], layout[2][col], layout[3][col], layout[4][col]]
    }
    
    private func placeCardsRandomly(_ allCards: [Card]) -> [[Card?]] {
        var newLayout = Array(repeating: Array(repeating: nil as Card?, count: 5), count: 5)
        var cardIndex = 0
        for row in 0..<5 {
            for col in 0..<5 {
                if cardIndex < allCards.count {
                    newLayout[row][col] = allCards[cardIndex]
                    cardIndex += 1
                }
            }
        }
        return newLayout
    }
    
    private func hasDuplicateCards() -> Bool {
        var seenCards = Set<String>()
        for row in 0..<5 {
            for col in 0..<5 {
                if let card = cards[row][col] {
                    let cardString = "\(card.suit) \(card.rank)"
                    if seenCards.contains(cardString) {
                        print("Warning: Duplicate card found: \(cardString)")
                        return true
                    }
                    seenCards.insert(cardString)
                }
            }
        }
        return false
    }
    
    private func setupPrototypePuzzle() {
        // Define all the cards needed for the puzzle
        let allCards: [Card] = [
            // Row 0: All Spades
            Card(suit: .spades, rank: .ace),
            Card(suit: .spades, rank: .king),
            Card(suit: .spades, rank: .queen),
            Card(suit: .spades, rank: .jack),
            Card(suit: .spades, rank: .ten),
            
            // Row 1: Three 8s
            Card(suit: .spades, rank: .eight),
            Card(suit: .hearts, rank: .eight),
            Card(suit: .diamonds, rank: .eight),
            Card(suit: .hearts, rank: .two),
            Card(suit: .hearts, rank: .three),
            
            // Row 2: Royal Court
            Card(suit: .clubs, rank: .eight),
            Card(suit: .hearts, rank: .king),
            Card(suit: .hearts, rank: .queen),
            Card(suit: .hearts, rank: .jack),
            Card(suit: .hearts, rank: .four),
            
            // Row 3: Pair of 9s
            Card(suit: .diamonds, rank: .king),
            Card(suit: .hearts, rank: .nine),
            Card(suit: .diamonds, rank: .nine),
            Card(suit: .hearts, rank: .six),
            Card(suit: .hearts, rank: .seven),
            
            // Row 4: Pair of 10s
            Card(suit: .hearts, rank: .ten),
            Card(suit: .diamonds, rank: .ten),
            Card(suit: .clubs, rank: .nine),
            Card(suit: .clubs, rank: .six),
            Card(suit: .clubs, rank: .seven)
        ]
        
        // Set up row conditions
        rowConditions = [
            CardCondition.allSameSuit,    // Row 0: All Spades
            CardCondition.threeOfAKind,   // Row 1: Three 8s
            CardCondition.royalCourt,     // Row 2: Royal Court
            CardCondition.pair,           // Row 3: Pair of 9s
            CardCondition.pair            // Row 4: Pair of 10s
        ]

        columnConditions = [
            CardCondition.pair,           // Column 0: Pair of Kings
            CardCondition.pair,           // Column 1: Pair of 8s
            CardCondition.pair,           // Column 2: Pair of Queens
            CardCondition.pair,           // Column 3: Pair of 6s
            CardCondition.pair            // Column 4: Pair of 7s
        ]
        
        // Verify no duplicates in initial setup
        var seenCards = Set<String>()
        for card in allCards {
            let cardString = "\(card.suit) \(card.rank)"
            if seenCards.contains(cardString) {
                print("ERROR: Duplicate card found in initial setup: \(cardString)")
                fatalError("Puzzle setup contains duplicate cards")
            }
            seenCards.insert(cardString)
        }
        
        // Place cards in initial solved state for preview
        let initialCards = [
            // Row 0: All Spades
            [Card(suit: .spades, rank: .ace),
             Card(suit: .spades, rank: .king),
             Card(suit: .spades, rank: .queen),
             Card(suit: .spades, rank: .jack),
             Card(suit: .spades, rank: .ten)],
            
            // Row 1: Three 8s
            [Card(suit: .spades, rank: .eight),
             Card(suit: .hearts, rank: .eight),
             Card(suit: .diamonds, rank: .eight),
             Card(suit: .hearts, rank: .two),
             Card(suit: .hearts, rank: .three)],
            
            // Row 2: Royal Court
            [Card(suit: .clubs, rank: .eight),
             Card(suit: .hearts, rank: .king),
             Card(suit: .hearts, rank: .queen),
             Card(suit: .hearts, rank: .jack),
             Card(suit: .hearts, rank: .four)],
            
            // Row 3: Pair of 9s
            [Card(suit: .diamonds, rank: .king),
             Card(suit: .hearts, rank: .nine),
             Card(suit: .diamonds, rank: .nine),
             Card(suit: .hearts, rank: .six),
             Card(suit: .hearts, rank: .seven)],
            
            // Row 4: Pair of 10s
            [Card(suit: .hearts, rank: .ten),
             Card(suit: .diamonds, rank: .ten),
             Card(suit: .clubs, rank: .nine),
             Card(suit: .clubs, rank: .six),
             Card(suit: .clubs, rank: .seven)]
        ]
        
        // Set both cards and solutionCards to the initial state
        cards = initialCards
        solutionCards = initialCards
        
        // Initialize empty card variants
        emptyCardVariants = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
        
        // Validate the puzzle using PuzzleValidator
        let (isValid, issues) = PuzzleValidator.validatePuzzle(cards: cards, rowConditions: rowConditions, columnConditions: columnConditions)
        
        if !isValid {
            print("WARNING: Puzzle validation failed!")
            issues.forEach { print("- \($0)") }
        } else {
            print("Puzzle validation successful!")
        }
    }
    
    private func checkPokerHand(cards: [Card], hand: PokerHand) -> Bool {
        print("\nChecking poker hand: \(hand)")
        print("Cards: \(cards.map { "\($0.suit) \($0.rank)" })")
        
        let result: Bool
        switch hand {
        case .pair:
            let values = cards.map { $0.rank.numericValue }
            let valueCounts = Dictionary(grouping: values, by: { $0 }).mapValues { $0.count }
            result = valueCounts.contains { $0.value >= 2 }
            print("Pair check - Value counts: \(valueCounts), Result: \(result)")
            
        case .threeOfAKind:
            let values = cards.map { $0.rank.numericValue }
            let valueCounts = Dictionary(grouping: values, by: { $0 }).mapValues { $0.count }
            result = valueCounts.contains { $0.value >= 3 }
            print("Three of a Kind check - Value counts: \(valueCounts), Result: \(result)")
            
        case .straight:
            let values = cards.map { $0.rank.numericValue }.sorted()
            if values.count < 5 {
                print("Straight check - Not enough cards: \(values.count)")
                return false
            }
            let first = values[0]
            let last = values[values.count - 1]
            result = last - first == values.count - 1
            print("Straight check - Values: \(values), First: \(first), Last: \(last), Result: \(result)")
            
        case .flush:
            result = cards.allSatisfy { $0.suit == cards[0].suit }
            print("Flush check - All suits: \(cards.map { $0.suit }), Result: \(result)")
            
        case .fullHouse:
            let values = cards.map { $0.rank.numericValue }
            let valueCounts = Dictionary(grouping: values, by: { $0 }).mapValues { $0.count }
            result = valueCounts.contains { $0.value >= 3 } && valueCounts.contains { $0.value >= 2 }
            print("Full House check - Value counts: \(valueCounts), Result: \(result)")
            
        case .fourOfAKind:
            let values = cards.map { $0.rank.numericValue }
            let valueCounts = Dictionary(grouping: values, by: { $0 }).mapValues { $0.count }
            result = valueCounts.contains { $0.value >= 4 }
            print("Four of a Kind check - Value counts: \(valueCounts), Result: \(result)")
        }
        
        print("Final result: \(result)")
        return result
    }
    
    func isConditionSatisfied(cards: [Card?], condition: CardCondition) -> Bool {
        let validCards = cards.compactMap { $0 }
        print("\nChecking condition: \(formatCondition(condition))")
        print("Valid cards: \(validCards.map { "\($0.suit) \($0.rank)" })")
        
        let result: Bool
        switch condition {
        case .allHearts:
            result = validCards.allSatisfy { $0.suit == .hearts }
            print("All hearts: \(result)")
            
        case .threeQueens:
            result = validCards.filter { $0.rank == .queen }.count == 3
            print("Three queens: \(result)")
            
        case .ascendingSequence:
            let values = validCards.map { $0.rank.numericValue }.sorted()
            result = values == Array(values[0]...(values[0] + values.count - 1))
            print("Ascending sequence check: \(values) == \(values.sorted()): \(result)")
            
        case .fourSevens:
            result = validCards.filter { $0.rank == .seven }.count == 4
            print("Four sevens: \(result)")
            
        case .allFaceCards:
            result = validCards.allSatisfy { $0.rank.isFaceCard() }
            print("All face cards: \(result)")
        
        case .threeOfAKind:
            result = checkPokerHand(cards: validCards, hand: .threeOfAKind)
            print("Three of a Kind check: \(result)")
            
        case .flush:
            result = validCards.allSatisfy { $0.suit == validCards[0].suit }
            print("Flush check: \(result)")
            
        case .straight:
            result = checkPokerHand(cards: validCards, hand: .straight)
            print("Straight check: \(result)")
            
        case .pair:
            result = checkPokerHand(cards: validCards, hand: .pair)
            print("Pair check: \(result)")
            
        case .allSameSuit:
            if validCards.count != 5 { return false }
            // Count cards of each suit
            let suitCounts = Dictionary(grouping: validCards, by: { $0.suit }).mapValues { $0.count }
            // Check if any suit has exactly 5 cards
            result = suitCounts.contains { $0.value == 5 }
            print("All same suit check - Suit counts: \(suitCounts), Result: \(result)")
            
        case .descending:
            let values = validCards.map { $0.rank.numericValue }.sorted().reversed()
            result = Array(values) == values.sorted()
            print("Descending check: \(values) == \(values.sorted()): \(result)")
            
        case .sumEquals:
            let sum = validCards.reduce(into: 0) { $0 += $1.rank.numericValue }
            result = sum == 15 // Using a fixed sum for now
            print("Sum check: \(sum) == 15: \(result)")
            
        case .pokerHand:
            result = checkPokerHand(cards: validCards, hand: .threeOfAKind)
            print("Poker hand check: \(result)")
            
        case .allSameRank:
            result = validCards.allSatisfy { $0.rank == validCards[0].rank }
            print("All same rank: \(result)")
            
        case .royalCourt:
            // Find one each of King, Queen, and Jack
            var foundKing = false
            var foundQueen = false
            var foundJack = false
            
            for card in validCards {
                if !foundKing && card.rank == .king {
                    foundKing = true
                } else if !foundQueen && card.rank == .queen {
                    foundQueen = true
                } else if !foundJack && card.rank == .jack {
                    foundJack = true
                }
            }
            
            let isSatisfied = foundKing && foundQueen && foundJack
            print("Royal Court check - Found King: \(foundKing), Queen: \(foundQueen), Jack: \(foundJack): \(isSatisfied)")
            return isSatisfied
        }
        
        print("Final result: \(result)")
        return result
    }
    
    func getSatisfyingCards(for condition: CardCondition, in cards: [Card?]) -> Set<Int> {
        let validCards = cards.compactMap { $0 }
        var satisfyingIndices = Set<Int>()
        
        switch condition {
        case .allHearts:
            // Find all hearts
            for (index, card) in cards.enumerated() {
                if let card = card, card.suit == .hearts {
                    satisfyingIndices.insert(index)
                }
            }
            
        case .threeQueens:
            // Find three queens
            for (index, card) in cards.enumerated() {
                if let card = card, card.rank == .queen {
                    satisfyingIndices.insert(index)
                }
            }
            
        case .ascendingSequence:
            // Find the sequence of cards in ascending order
            let sortedCards = validCards.sorted { $0.rank.numericValue < $1.rank.numericValue }
            if sortedCards.count >= 5 {
                let values = sortedCards.map { $0.rank.numericValue }
                if values[4] - values[0] == 4 {
                    // Find the indices of these cards in the original array
                    for (index, card) in cards.enumerated() {
                        if let card = card, values.contains(card.rank.numericValue) {
                            satisfyingIndices.insert(index)
                        }
                    }
                }
            }
            
        case .fourSevens:
            // Find four sevens
            for (index, card) in cards.enumerated() {
                if let card = card, card.rank == .seven {
                    satisfyingIndices.insert(index)
                }
            }
            
        case .allFaceCards:
            // Find all face cards
            for (index, card) in cards.enumerated() {
                if let card = card, card.rank.isFaceCard() {
                    satisfyingIndices.insert(index)
                }
            }
            
        case .threeOfAKind:
            // Find all three cards of the same rank
            let values = validCards.map { $0.rank.numericValue }
            let valueCounts = Dictionary(grouping: values, by: { $0 }).mapValues { $0.count }
            if let targetValue = valueCounts.first(where: { $0.value >= 3 })?.key {
                var count = 0
                for (index, card) in cards.enumerated() {
                    if let card = card, card.rank.numericValue == targetValue {
                        satisfyingIndices.insert(index)
                        count += 1
                        if count >= 3 {
                            break
                        }
                    }
                }
            }
            
        case .flush:
            // Find all cards of the same suit
            if let firstSuit = validCards.first?.suit {
                for (index, card) in cards.enumerated() {
                    if let card = card, card.suit == firstSuit {
                        satisfyingIndices.insert(index)
                    }
                }
            }
            
        case .straight:
            // Find the sequence of cards in ascending order
            let sortedCards = validCards.sorted { $0.rank.numericValue < $1.rank.numericValue }
            if sortedCards.count >= 5 {
                let values = sortedCards.map { $0.rank.numericValue }
                if values[4] - values[0] == 4 {
                    // Find the indices of these cards in the original array
                    for (index, card) in cards.enumerated() {
                        if let card = card, values.contains(card.rank.numericValue) {
                            satisfyingIndices.insert(index)
                        }
                    }
                }
            }
            
        case .pair:
            // Find the first two cards of the same rank
            let values = validCards.map { $0.rank.numericValue }
            if let firstValue = values.first(where: { value in
                values.filter { $0 == value }.count >= 2
            }) {
                // Find the first two indices of cards with this value
                var count = 0
                for (index, card) in cards.enumerated() {
                    if let card = card, card.rank.numericValue == firstValue {
                        satisfyingIndices.insert(index)
                        count += 1
                        if count >= 2 {
                            break
                        }
                    }
                }
            }
            
        case .allSameSuit:
            // Find all cards of the same suit
            if let firstSuit = validCards.first?.suit {
                for (index, card) in cards.enumerated() {
                    if let card = card, card.suit == firstSuit {
                        satisfyingIndices.insert(index)
                    }
                }
            }
            
        case .descending:
            // Find the sequence of cards in descending order
            let sortedCards = validCards.sorted { $0.rank.numericValue > $1.rank.numericValue }
            if sortedCards.count >= 5 {
                let values = sortedCards.map { $0.rank.numericValue }
                if values[0] - values[4] == 4 {
                    // Find the indices of these cards in the original array
                    for (index, card) in cards.enumerated() {
                        if let card = card, values.contains(card.rank.numericValue) {
                            satisfyingIndices.insert(index)
                        }
                    }
                }
            }
            
        case .sumEquals:
            // Find the combination of cards that sum to the target
            let values = validCards.map { $0.rank.numericValue }
            for i in 0..<values.count {
                for j in (i+1)..<values.count {
                    for k in (j+1)..<values.count {
                        for l in (k+1)..<values.count {
                            for m in (l+1)..<values.count {
                                if values[i] + values[j] + values[k] + values[l] + values[m] == 15 {
                                    // Find the indices of these cards in the original array
                                    let targetValues = [values[i], values[j], values[k], values[l], values[m]]
                                    for (index, card) in cards.enumerated() {
                                        if let card = card, targetValues.contains(card.rank.numericValue) {
                                            satisfyingIndices.insert(index)
                                        }
                                    }
                                    return satisfyingIndices
                                }
                            }
                        }
                    }
                }
            }
            
        case .pokerHand:
            // Find all three cards of the same rank
            let values = validCards.map { $0.rank.numericValue }
            if let targetValue = values.first(where: { value in
                values.filter { $0 == value }.count >= 3
            }) {
                for (index, card) in cards.enumerated() {
                    if let card = card, card.rank.numericValue == targetValue {
                        satisfyingIndices.insert(index)
                    }
                }
            }
            
        case .allSameRank:
            // Find all cards of the specified rank
            for (index, card) in cards.enumerated() {
                if let card = card, card.rank == validCards[0].rank {
                    satisfyingIndices.insert(index)
                }
            }
            
        case .royalCourt:
            // Find one each of King, Queen, and Jack
            var foundKing = false
            var foundQueen = false
            var foundJack = false
            
            for (index, card) in cards.enumerated() {
                if let card = card {
                    if !foundKing && card.rank == .king {
                        foundKing = true
                        satisfyingIndices.insert(index)
                    } else if !foundQueen && card.rank == .queen {
                        foundQueen = true
                        satisfyingIndices.insert(index)
                    } else if !foundJack && card.rank == .jack {
                        foundJack = true
                        satisfyingIndices.insert(index)
                    }
                }
            }
            
            let isSatisfied = foundKing && foundQueen && foundJack
            print("Royal Court check - Found King: \(foundKing), Queen: \(foundQueen), Jack: \(foundJack): \(isSatisfied)")
            
            // Only return the indices if we found all three royal cards
            if !isSatisfied {
                satisfyingIndices.removeAll()
            }
        }
        
        return satisfyingIndices
    }
    
    func formatCondition(_ condition: CardCondition) -> String {
        switch condition {
        case .allHearts:
            return "All ♥"
        case .threeQueens:
            return "3 Queens"
        case .ascendingSequence:
            return "Low to high"
        case .fourSevens:
            return "4 Sevens"
        case .allFaceCards:
            return "All face cards"
        case .threeOfAKind:
            return "3 of a kind"
        case .flush:
            return "Flush"
        case .straight:
            return "Straight"
        case .pair:
            return "Pair"
        case .allSameSuit:
            return "All same suit"
        case .descending:
            return "High to Low"
        case .sumEquals:
            return "Sum=15"
        case .pokerHand:
            return "3 of a kind"
        case .allSameRank:
            return "All same rank"
        case .royalCourt:
            return "Royal Court"
        }
    }
    
    func checkAllConditions() {
        print("\n=== Checking All Conditions ===")
        var newSatisfiedRows = Set<Int>()
        
        // Check all rows
        print("\nChecking Rows:")
        for row in 0..<5 {
            let rowCards = cards[row]
            print("\nRow \(row):")
            let rowCardStrings = rowCards.compactMap { (card: Card?) -> String? in
                guard let card = card else { return nil }
                return "\(card.suit) \(card.rank)"
            }
            print("Cards: \(rowCardStrings)")
            print("Condition: \(rowConditions[row])")
            if isConditionSatisfied(cards: rowCards, condition: rowConditions[row]) {
                print("Row \(row) condition satisfied!")
                newSatisfiedRows.insert(row)
            }
        }
        
        // ... rest of the method ...
    }
} 
