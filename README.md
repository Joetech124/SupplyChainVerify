# SupplyChainVerify

A blockchain-based verification system for fashion supply chains built on the Stacks blockchain.

## Overview

SupplyChainVerify provides transparency and authenticity verification for fashion products by tracking their journey through the supply chain. Manufacturers can register products with detailed information, and authorized verifiers can certify the authenticity of these products.

## Features

- Register fashion products with detailed information
- Authorized verification of product authenticity
- Transparent supply chain tracking
- Immutable record of product history

## Smart Contract Functions

### Register Product
Allows manufacturers to register new products with details including name, materials, production date, and location.

### Verify Product
Enables authorized verifiers to certify the authenticity of registered products.

### Read-only Functions
- `get-product`: Retrieve details for a specific product
- `get-manufacturer-products`: Get all products registered by a specific manufacturer
- `is-verifier`: Check if an address is an authorized verifier

## Getting Started

1. Clone this repository
2. Install [Clarinet](https://github.com/hirosystems/clarinet)
3. Run `clarinet check` to verify the contract
4. Deploy using Clarinet or the Stacks CLI