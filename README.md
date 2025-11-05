A blockchain-based solution for transparent political campaign funding using Stacks and Clarity smart contracts.

## 🎯 Problem Statement

Political campaign funding lacks transparency, enabling corruption and reducing public trust in democratic processes.

## ✅ Solution

This smart contract creates an immutable, public ledger for political donations and campaign expenses, ensuring complete financial transparency.

## 🚀 Features

- 📝 **Campaign Registration**: Candidates can register their campaigns
- 💰 **Donation Tracking**: All donations are recorded with donor information
- 🧾 **Expense Recording**: Campaign expenses with receipt verification
- 📊 **Real-time Analytics**: Transparency scores and compliance checking
- 🔍 **Public Auditing**: Anyone can verify campaign finances
- ⏸️ **Campaign Pause/Resume**: Flexible campaign management with pause and resume capabilities
- 🛡️ **Immutable Records**: Blockchain-based tamper-proof storage

## 📋 Contract Functions

### Public Functions

| Function | Description |
|----------|-------------|
| `register-campaign` | Register a new political campaign |
| `make-donation` | Make a donation to a campaign |
| `record-expense` | Record campaign expense (candidate only) |
| `close-campaign` | Close campaign (candidate only) |
| `pause-campaign` | Pause campaign (candidate only) |
| `resume-campaign` | Resume paused campaign (candidate only) |
| `propose-expense` | Propose a campaign expense for donor voting (candidate only) |
| `vote-on-expense` | Vote on a proposed expense (donors only) |
| `finalize-expense-proposal` | Finalize voting and record approved expense (candidate only) |

### Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-campaign` | Get campaign details |
| `get-donation` | Get donation information |
| `get-expense` | Get expense record |
| `get-expense-proposal` | Get expense proposal details |
| `get-donor-vote` | Get donor vote on a proposal |
| `get-campaign-stats` | Get campaign financial statistics |
| `get-transparency-score` | Calculate transparency score |
| `is-campaign-compliant` | Check campaign compliance |

## 🔧 Usage

### Deploy Contract

```bash
clarinet deploy
```

### Register Campaign

```clarity
(contract-call? .election-campaign-finance-transparency register-campaign "Jane Doe for Mayor")
```

### Make Donation

```clarity
(contract-call? .election-campaign-finance-transparency make-donation u1 u1000000)
```

### Record Expense

```clarity
(contract-call? .election-campaign-finance-transparency record-expense u1 "Campaign office rent" u500000 "Property Management LLC" "abc123def456")
```

### Query Campaign Stats

```clarity
(contract-call? .election-campaign-finance-transparency get-campaign-stats u1)
```

## 🏗️ Development

### Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet/)
- Node.js 16+

### Setup

```bash
git clone https://github.com/your-username/election-campaign-finance-transparency
cd election-campaign-finance-transparency
clarinet check
```

### Testing

```bash
clarinet test
```

### Local Deployment

```bash
clarinet console
```

## 📊 Data Structure

- Status: Active/Paused/Closed
### Campaign
- ID, Name, Candidate
- Total Raised/Spent
- Status, Creation Date

### Donations
- Campaign ID, Donor Address
- Amount, Timestamp
### Expense Proposals
- Proposal ID, Campaign ID, Description
- Amount, Recipient, Receipt Hash
- Vote Counts (For/Against), Finalized Status
- Proposer, Creation Timestamp

### Donor Votes
- Proposal ID, Donor Address
- Vote (Yes/No)
- Verification Status
- ✅ Donor voting rights for expense approval
- ✅ Majority vote requirement for expense approval
- ✅ One vote per donor per proposal
- ✅ Immutable voting records

- 🗳️ **Community Governance**: Donors actively participate in expense decisions
- 🛡️ **Enhanced Accountability**: Multiple layers of approval for campaign spending
- 🤝 **Trust Enhancement**: Democratic control over campaign finances
- 📊 **Transparent Voting**: Public visibility of all expense votes and decisions
### Expenses
- Campaign ID, Description
- Amount, Recipient
- Receipt Hash, Timestamp

## 🔒 Security Features

- ✅ Access control for campaign management
- ✅ Spending limits (cannot exceed donations)
- ✅ Immutable transaction records
- ✅ Public verification system

## 🌟 Benefits

- 🌍 **Public Transparency**: All transactions are publicly verifiable
- 🚫 **Anti-Corruption**: Immutable records prevent manipulation
- 📈 **Real-time Tracking**: Live campaign finance monitoring
- 🎯 **Accountability**: Candidates accountable for every dollar
- 🤝 **Trust Building**: Increases public confidence in elections

## 📄 License

MIT License

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Submit pull request

---

*Built with ❤️ for democratic transparency*

- 🗳️ **Donor Voting on Expenses**: Donors can vote on proposed campaign expenses, ensuring community oversight and accountability
- 📋 **Expense Proposals**: Candidates propose expenses which donors can approve or reject through voting
- 🏛️ **Democratic Expense Control**: Expenses only get recorded if approved by majority donor vote
