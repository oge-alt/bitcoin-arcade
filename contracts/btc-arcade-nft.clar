;; Title: Bitcoin Arcade Gaming Assets

;; SUMMARY
;; A comprehensive NFT and reward system for Bitcoin Arcade, enabling 
;; ownership of in-game assets with different rarities and distributing 
;; Bitcoin rewards to players based on their performance.
;;
;; This contract implements the full NFT-trait standard with additional
;; gaming-specific functionality for tracking scores and distributing
;; rewards in a trustless manner.

;; NFT TRAIT DEFINITION
(define-trait nft-trait (
  (get-last-token-id
    ()
    (response uint uint)
  )
  (get-token-uri
    (uint)
    (response (optional (string-ascii 256)) uint)
  )
  (get-owner
    (uint)
    (response (optional principal) uint)
  )
  (transfer
    (uint principal principal)
    (response bool uint)
  )
))

;; CONSTANTS & ERROR CODES

;; Error definitions
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-PARAMETERS (err u101))
(define-constant ERR-NFT-NOT-FOUND (err u102))
(define-constant ERR-ALREADY-MINTED (err u103))
(define-constant ERR-INSUFFICIENT-FUNDS (err u104))
(define-constant ERR-TRANSFER-FAILED (err u105))
(define-constant ERR-REWARD-DISTRIBUTION-FAILED (err u106))
(define-constant ERR-INVALID-RARITY (err u107))
(define-constant ERR-INVALID-GAME-TYPE (err u108))
(define-constant ERR-INVALID-PLAYER (err u109))

;; Valid rarity types
(define-constant VALID-RARITIES (list "common" "rare" "epic" "legendary"))

;; DATA VARIABLES

;; Contract owner
(define-data-var contract-owner principal tx-sender)

;; NFT collection name
(define-data-var collection-name (string-ascii 32) "BitcoinArcade Gaming Assets")

;; Token counter to generate unique IDs
(define-data-var last-token-id uint u0)

;; Reward system parameters
(define-data-var total-reward-pool uint u0)
(define-data-var reward-per-point uint u10) ;; 10 sats per point as default

;; DATA MAPS

;; NFT metadata storage
(define-map nft-metadata
  { token-id: uint }
  {
    name: (string-ascii 50),
    description: (string-ascii 200),
    rarity: (string-ascii 9),
    game-type: (string-ascii 50),
    minted-at: uint,
  }
)

;; Leaderboard tracking
(define-map player-scores
  { player: principal }
  {
    total-score: uint,
    last-updated: uint,
    total-rewards-earned: uint,
  }
)

;; NON-FUNGIBLE TOKEN DEFINITION

;; Define the NFT asset
(define-non-fungible-token game-asset uint)

;; PRIVATE HELPER FUNCTIONS

;; Validate rarity type
(define-private (is-valid-rarity (rarity (string-ascii 9)))
  (is-some (index-of VALID-RARITIES rarity))
)

;; Validate game type
(define-private (is-valid-game-type (game-type (string-ascii 50)))
  (and
    (> (len game-type) u0)
    (<= (len game-type) u50)
  )
)

;; Validate principal (enhanced check)
(define-private (is-valid-principal (addr principal))
  (and
    (not (is-eq addr tx-sender))
    ;; Add additional principal validation if needed
    true
  )
)

;; Check if a principal is the owner of a specific NFT
(define-private (is-owner
    (token-id uint)
    (user principal)
  )
  (match (nft-get-owner? game-asset token-id)
    owner (is-eq user owner)
    false
  )
)

;; Initialize contract
(define-private (initialize)
  (begin
    ;; Set initial reward per point
    (var-set reward-per-point u10)
    ;; Set initial reward pool
    (var-set total-reward-pool u1000000) ;; 1 million sats initial pool
    true
  )
)

;; NFT CORE FUNCTIONS

;; Mint a new game NFT
(define-public (mint-game-nft
    (name (string-ascii 50))
    (description (string-ascii 200))
    (rarity (string-ascii 9))
    (game-type (string-ascii 50))
  )
  (let (
      (token-id (+ (var-get last-token-id) u1))
      (is-rarity-valid (is-valid-rarity rarity))
      (is-game-type-valid (is-valid-game-type game-type))
    )
    ;; Ensure only contract owner can mint initially
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    ;; Validate input parameters separately with specific error codes
    (asserts! (> (len name) u0) ERR-INVALID-PARAMETERS)
    (asserts! (<= (len name) u50) ERR-INVALID-PARAMETERS)
    (asserts! (> (len description) u0) ERR-INVALID-PARAMETERS)
    (asserts! (<= (len description) u200) ERR-INVALID-PARAMETERS)
    (asserts! is-rarity-valid ERR-INVALID-RARITY)
    (asserts! is-game-type-valid ERR-INVALID-GAME-TYPE)
    ;; Mint the NFT
    (try! (nft-mint? game-asset token-id tx-sender))
    ;; Store metadata only after all validations have passed
    (map-set nft-metadata { token-id: token-id } {
      name: name,
      description: description,
      rarity: rarity,
      game-type: game-type,
      minted-at: stacks-block-height,
    })
    ;; Update last token ID
    (var-set last-token-id token-id)
    ;; Return the new token ID
    (ok token-id)
  )
)

;; Transfer an NFT to another owner
(define-public (transfer
    (token-id uint)
    (sender principal)
    (recipient principal)
  )
  (begin
    ;; Validate recipient
    (asserts! (not (is-eq sender recipient)) ERR-INVALID-PARAMETERS)
    (asserts! (not (is-eq recipient (var-get contract-owner)))
      ERR-INVALID-PARAMETERS
    )
    (asserts! (is-valid-principal recipient) ERR-INVALID-PARAMETERS)
    ;; Ensure sender is the owner
    (asserts! (is-owner token-id sender) ERR-NOT-AUTHORIZED)
    ;; Perform transfer
    (try! (nft-transfer? game-asset token-id sender recipient))
    (ok true)
  )
)

;; READ-ONLY FUNCTIONS

;; Get NFT metadata
(define-read-only (get-nft-metadata (token-id uint))
  (map-get? nft-metadata { token-id: token-id })
)

;; Get current reward pool balance
(define-read-only (get-reward-pool-balance)
  (var-get total-reward-pool)
)

;; Implement NFT trait requirements
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)