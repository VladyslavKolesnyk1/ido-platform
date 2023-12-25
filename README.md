# IDO PLATFORM

## Description

IDO PLATFORM repostitory includes three primary smart contracts:

1. **IDO Creator**: A contract that facilitates the creation of new IDO contracts.
2. **FCFS IDO (First-Come-First-Serve IDO)**: This contract allows for multiple deposit tokens and utilizes Chainlink data feeds for accurate and secure pricing.
3. **Raffle IDO**: A raffle-style IDO contract that leverages a Merkle Tree for proving winnership, ensuring a fair and transparent selection process.

## Requirements

Before setting up the project, ensure you have the following tools installed:

* **Node.js**: Version 18 LTS. Download Node.js
* **Yarn**: Version 1 or 2+. Install Yarn
* **Git**: Install Git

## Quickstart

Follow these steps to get the project up and running:

### Clone the Repository


`git clone https://github.com/VladyslavKolesnyk1/ido-platform.git`

### Install Dependencies

`yarn install`

### Start Local Blockchain

`yarn chain`

### Deploy Contracts

First, fill in the constants.ts file with the necessary information.

Then, deploy the contracts:

`yarn deploy`

### Start the Application

`yarn start`

Visit your application at: http://localhost:3000

## Contracts Overview

### IDO Creator

This contract acts as a factory for creating new IDO instances. It ensures that each IDO, whether FCFS or Raffle style, is instantiated with consistent settings and proper initialization.

### FCFS IDO

The FCFS IDO contract allows participants to deposit various supported tokens (configured at creation) to participate in the IDO. Prices are determined using Chainlink data feeds, ensuring accurate and market-reflective pricing.

### Raffle IDO

Raffle IDO introduces a lottery-style mechanism into the IDO process. Participants purchase tickets, and winners are chosen through a verifiable random process using a Merkle Tree. This approach ensures fairness and transparency in the selection of participants who will receive the IDO tokens.
