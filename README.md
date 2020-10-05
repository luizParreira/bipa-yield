# Bipa Yield

Bipa yield is a series of smart contract experiments to
learn how we can generate yield for Bipa's users.
And any other Ethereum user for that matter.

## Context

Bipa is a mobile app that allows users to Buy and Sell Bitcoin and Gold (PAXG).
Our goal is to make it really easy for beginners to own a bit of Bitcoin, even
if just 1 BRL. It would be great, if we could also make it really easy for users
to generate yield on their Bitcoin by leveraging DeFi's yield farming.

## Design

There are two main clients for this simple protocol:

- Bipa users that have their Bitcoin stored with Bipa's node
- Browser users that connect through metamask or other wallet provider

## Stories

Stories for browser users

- As a user
- As a user of this protocol, I would like to be able to deposit my BTC staked into a
  contract that will maximize its yield.
- I would also like to be able to see how much yield I am getting
- Also, I need to be able to instant withdraw my funds, avoiding as much fees as possible, if possible
- As an user I want to accumulate as much BTC as possible

- Users should know their funds are being deposited into a DeFi contract.
- Users should be able to withdraw their funds into BTC almost instantly.
- Users' should start getting yield almost instantly.
- A % of user's yields should be used to pay for fees on the translation between WBTC and BTC
