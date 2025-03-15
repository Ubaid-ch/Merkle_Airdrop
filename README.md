# Merkle Airdrop Extravaganza 

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

## Quickstart

```bash
git clone https://github.com/Ubaid-ch/Merkle_Airdrop.git
cd Merkle_Airdrop
make # or forge install && forge build if you don't have make 
```

# Usage

## Pre-deploy: Generate merkle proofs

We are going to generate merkle proofs for an array of addresses to airdrop funds to. If you'd like to work with the default addresses and proofs already created in this repo, skip to [deploy](#deploy).

If you'd like to work with a different array of addresses (the `whitelist` list in `GenerateInput.s.sol`), you will need to follow the following steps:

```bash
make merkle
```

# Deploy 

## Deploy to Anvil

```bash
foundryup
make anvil
make deploy
```

# Interacting - Local anvil network

```bash
foundryup
make anvil
make deploy
make sign
make claim
make balance
```

# Testing

```bash
forge test
```

# Estimate gas

```bash
forge snapshot
```

# Formatting

```bash
forge fmt
```

# Thank you!

