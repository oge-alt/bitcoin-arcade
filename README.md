# 🎮 Bitcoin Arcade Gaming Assets

A **Clarity smart contract** system powering a trustless, NFT-driven gaming economy where players own unique game assets and earn **Bitcoin rewards** based on performance.

## 🔧 Key Features

* **NFT Game Assets**

  * Mint and transfer NFTs representing in-game assets
  * Rarity tiers: `common`, `rare`, `epic`, `legendary`
  * Metadata: name, description, game type, mint block height
  * Compliant with the Clarity `nft-trait` standard

* **Bitcoin Rewards**

  * Score-based reward mechanism
  * Secure and trustless Bitcoin reward distribution
  * Configurable reward pool and conversion rate

* **Leaderboard & Score Tracking**

  * Persistent player scores with timestamps
  * Total score and reward history stored on-chain

* **Admin Controls**

  * Role-based permissions for minting, scoring, and distributing
  * Adjustable reward pool and contract ownership

## 📐 Architecture Overview

### Modules

| Module          | Responsibility                                                |
| --------------- | ------------------------------------------------------------- |
| `NFT Engine`    | Minting, transferring, and managing metadata for game assets  |
| `Leaderboard`   | Recording player scores, timestamps, and maintaining rankings |
| `Reward System` | Converting scores to Bitcoin payouts from the reward pool     |

### Data Structures

**NFT Metadata**

```clarity
{
  name: (string-ascii 50),
  description: (string-ascii 200),
  rarity: (string-ascii 9),
  game-type: (string-ascii 50),
  minted-at: uint
}
```

**Player Profile**

```clarity
{
  total-score: uint,
  last-updated: uint,
  total-rewards-earned: uint
}
```

## 🔗 Smart Contract Functions

| Function                                            | Description                        |
| --------------------------------------------------- | ---------------------------------- |
| `mint-game-nft (name description rarity game-type)` | Creates new game asset NFT         |
| `record-player-score (player score)`                | Updates leaderboard with new score |
| `distribute-bitcoin-rewards (player)`               | Pays out Bitcoin rewards to player |
| `get-owner (token-id)`                              | Returns NFT owner                  |
| `get-token-uri (token-id)`                          | Returns NFT metadata URL           |
| `transfer (token-id from to)`                       | Transfers NFT ownership            |
| `add-to-reward-pool (amount)`                       | Adds sats to the reward pool       |
| `transfer-ownership (new-owner)`                    | Transfers contract ownership       |

## ⚖️ Reward System

**Reward Calculation**

```
reward = score × reward_rate
```

**Defaults**

* **Reward Rate**: 10 sats per point
* **Initial Pool**: 1,000,000 sats

**Controlled By**

* Contract admin via `add-to-reward-pool`
* Only admin can distribute or update scores

## 🧪 Usage Examples

### Mint a New NFT

```clarity
(mint-game-nft
  "BlasterBot"
  "A powerful in-game AI weapon"
  "epic"
  "ArcadeShooter")
```

### Record a Player Score

```clarity
(record-player-score tx-sender u500)
```

### Distribute Rewards

```clarity
(distribute-bitcoin-rewards tx-sender)
```

### Get NFT Owner

```clarity
(get-owner u42)
```

## 🛡️ Error Handling

| Code | Error                    | Description                |
| ---- | ------------------------ | -------------------------- |
| 100  | `ERR-NOT-AUTHORIZED`     | Unauthorized function call |
| 102  | `ERR-NFT-NOT-FOUND`      | Token ID doesn't exist     |
| 104  | `ERR-INSUFFICIENT-FUNDS` | Reward pool too low        |
| 107  | `ERR-INVALID-RARITY`     | Unsupported rarity type    |
| 110  | `ERR-INVALID-PARAMETERS` | Failed input validation    |

## 🖼️ Token URI Format

```
https://bitcoinarcade.io/assets/<token-id>
```

## 🛣️ Roadmap

1. **Bitcoin Oracle Integration**

   * Enable real BTC transfers on mainnet

2. **Crafting & Rarity Mechanics**

   * In-game item evolution and rarity boosts

3. **Asset Marketplace**

   * Trade, rent, and auction NFTs on-chain

4. **Lightning Network Support**

   * Real-time, low-fee Bitcoin payments

5. **DAO Governance**

   * Community control over reward pool and game parameters
