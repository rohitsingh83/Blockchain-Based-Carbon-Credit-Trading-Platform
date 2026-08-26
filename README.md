# Carbon Credit Trading Platform

An educational blockchain prototype that simulates the lifecycle of tokenized carbon credits: project registration, issuer-controlled issuance, wallet transfers, fixed-price marketplace trading, escrowed listings, settlement, proceeds withdrawal, and irreversible retirement.

> **Educational prototype only.** The credits and project data in this repository are simulated. They are not legally recognized carbon credits, verified offsets, or assets connected to a real registry or issuer. Do not use real funds with this project.

## Features

* Project registration with registry reference and metadata URI
* Issuer-only carbon credit issuance
* Project-scoped balances so credits from different projects remain distinct
* Wallet-to-wallet credit transfers
* Allowance / `transferFrom` support
* Fixed-price marketplace listings
* Escrowed credits while a listing is active
* Partial purchases from listings
* Seller proceeds accounting and withdrawal
* Permanent credit retirement with a retirement reason
* Solidity events for project creation, issuance, transfers, listings, purchases, and retirement
* Reentrancy protection on ETH-settling and proceeds-withdrawal flows
* Hardhat test coverage for issuer permissions, transfers, purchases, and retirement
* Static demo dashboard in `docs/`

## Technology Stack

| Technology          | Purpose                                  |
| ------------------- | ---------------------------------------- |
| Solidity 0.8.24     | Smart contract                           |
| Hardhat             | Compile, test, and local blockchain      |
| Ethers.js           | Contract deployment and test interaction |
| JavaScript          | Scripts and tests                        |
| HTML/CSS/JavaScript | Static demo dashboard                    |

## Architecture

```text
Issuer
  │
  ├── createProject()
  ├── issueCredits()
  │
  ▼
CarbonCreditMarketplace.sol
  │
  ├── Project Registry
  ├── Project-Scoped Balances
  ├── Transfers / Allowances
  ├── Escrow Listings
  ├── Fixed-Price Purchases
  ├── Seller Proceeds
  └── Credit Retirement
  │
  ├───────────────┬───────────────┐
  ▼               ▼               ▼
Seller          Buyer          Retiree
  │               │               │
  ├─ list         ├─ buy          └─ retire
  └─ withdraw     └─ receive

Blockchain / Hardhat Network
  │
  └── Immutable transactions + emitted events
```

## Smart Contract Lifecycle

1. The deployer becomes the immutable `issuer`.
2. The issuer creates a simulated carbon project.
3. The issuer issues project-scoped credits to a wallet.
4. Holders may transfer credits directly or through approved allowances.
5. A seller creates a marketplace listing; listed credits are moved into escrow.
6. A buyer purchases some or all of the listed amount at the fixed price.
7. Purchased credits are credited to the buyer and the seller receives recorded proceeds.
8. The seller withdraws accumulated proceeds.
9. A holder can retire credits permanently; the balance is reduced and the project retirement total is increased.

## Project Structure

```text
Carbon-Credit-Trading-Platform/
├── contracts/
│   └── CarbonCreditMarketplace.sol
├── scripts/
│   └── deploy.js
├── test/
│   └── CarbonCreditMarketplace.test.js
├── docs/
│   ├── index.html
│   ├── app.js
│   ├── styles.css
│   └── README.md
├── screenshot/
│   └── 1.jpe
├── hardhat.config.js
├── package.json
├── package-lock.json
├── .gitignore
└── README.md
```

## Getting Started

### Prerequisites

* Node.js and npm
* A terminal / command prompt

### Install dependencies

```bash
npm install
```

### Compile

```bash
npm run compile
```

### Run tests

```bash
npm test
```

### Start a local blockchain

```bash
npm run node
```

In a second terminal:

```bash
npm run deploy:local
```

### Run the demo dashboard

```bash
npm run demo
```

Then open `http://localhost:4173`.

## Key Contract Functions

### Issuer

* `createProject(...)` — registers a simulated carbon project.
* `issueCredits(...)` — issues project-scoped credits.

### Credit holders

* `approve(...)` — grants a spender an allowance.
* `transferCredits(...)` — transfers credits between wallets.
* `transferFrom(...)` — transfers approved credits.
* `createListing(...)` — places credits into marketplace escrow.
* `cancelListing(...)` — returns escrowed credits to the seller.
* `buyCredits(...)` — purchases credits at the listing price.
* `withdrawProceeds()` — withdraws accumulated seller proceeds.
* `retireCredits(...)` — permanently retires credits.

## Testing Coverage

The included test suite verifies the main prototype rules:

* Only the issuer can issue credits.
* Credits transfer correctly between wallets.
* Listings escrow the seller inventory.
* Buyers can partially fill a fixed-price listing.
* Seller proceeds are recorded correctly.
* Retirement reduces the holder balance and increases the project retirement total.

## Security Considerations

The contract includes several basic safeguards:

* `onlyIssuer` restricts project creation and issuance.
* `nonReentrant` protects ETH settlement and proceeds withdrawal.
* Listing creation moves credits out of the seller balance to avoid double-listing the same inventory.
* A retired balance is removed from the holder before the retirement total is updated.
* Zero-address and zero-amount validations are applied to core operations.

This is not a security audit. Production deployment would require independent auditing, robust role management, identity/KYC controls, verified environmental data, oracle design, legal review, registry integration, sanctions screening, and a formal token standard where appropriate.

## Production Gaps

This prototype deliberately leaves out several real-world requirements:

* Independent project verification and MRV
* Real registry integration
* Legal classification of credits
* KYC/AML and participant identity controls
* Oracle integrity and trusted environmental data inputs
* Production-grade governance and access control
* Privacy and compliance requirements
* Formal tokenization standards and interoperability

## Suggested Future Enhancements

* ERC-1155-compatible credit tokenization
* Role-based issuer / verifier / marketplace permissions
* Registry verification workflow
* Oracle-backed project metadata and environmental measurements
* Marketplace search and filtering
* Multi-project analytics and portfolio views
* Deployment to a public testnet
* CI-based contract testing and static analysis

## GitHub Upload

Recommended repository name:

`Carbon-Credit-Trading-Platform`

Suggested topics:

`blockchain` `solidity` `carbon-credits` `carbon-trading` `ethereum` `smart-contract` `hardhat` `ethersjs` `web3` `climate-tech`

## Disclaimer

This repository is an educational software prototype. Simulated carbon credits in this project are not certified offsets, do not represent ownership of environmental assets, and should not be marketed or sold as real carbon credits.

## Author

Rohit Singh — GitHub: https://github.com/rohitsingh83
<img width="1600" height="980" alt="carbon_credit_architecture" src="https://github.com/user-attachments/assets/1602dae0-3a6a-4aa9-832d-420faf04a0f4" />
