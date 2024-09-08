#!/bin/bash
# First check that Leo is installed.
if ! command -v leo &> /dev/null
then
    echo "leo is not installed."
    exit
fi

# You need three leo wallets with some ALEO inorder to perform the transaction.
# Update the .env file with each wallet private key to perform the action

# The private key and address of the first bidder.
# Swap these into program.json, when running transactions as the first bidder.
# NETWORK=testnet
# PRIVATE_KEY=APrivateKey1zFIRST...

# The private key and address of the second bidder.
# Swap these into program.json, when running transactions as the second bidder.
# NETWORK=testnet
# PRIVATE_KEY=APrivateKey1zSECOND...


# The private key and address of the auctioneer.
# Swap these into program.json, when running transactions as the auctioneer.
# NETWORK=testnet
# PRIVATE_KEY=APrivateKey1zAUCTIONEER...


echo "
###############################################################################
########                                                               ########
########            STEP 0: Initialize a new 2-party auction           ########
########                                                               ########
########                -------------------------------                ########
########                |  OPEN   |    A    |    B    |                ########
########                -------------------------------                ########
########                |   Bid   |         |         |                ########
########                -------------------------------                ########
########                                                               ########
###############################################################################
"
# Swap in the private key and address of the first bidder to .env.
echo "
NETWORK=testnet
PRIVATE_KEY=APrivateKey1zFIRST...
ENDPOINT=https://localhost:3030
" > .env

# Have the first bidder place a bid of 10.
echo "
###############################################################################
########                                                               ########
########          STEP 1: The first bidder places a bid of 10          ########
########                                                               ########
########                -------------------------------                ########
########                |  OPEN   |    A    |    B    |                ########
########                -------------------------------                ########
########                |   Bid   |   10    |         |                ########
########                -------------------------------                ########
########                                                               ########
###############################################################################
"
leo run place_bid aleo1ashyu96tjwe63u0gtnnv8z5lhapdu4l5pjsl2kha7fv7hvz2eqxs5dz0rg 10u64 || exit

# Swap in the private key and address of the second bidder to .env.
echo "
NETWORK=testnet
PRIVATE_KEY=APrivateKey1zSECOND....
ENDPOINT=https://localhost:3030
" > .env

# Have the second bidder place a bid of 3.
echo "
###############################################################################
########                                                               ########
########         STEP 2: The second bidder places a bid of 3          ########
########                                                               ########
########                -------------------------------                ########
########                |  OPEN   |    A    |    B    |                ########
########                -------------------------------                ########
########                |   Bid   |   10    |   3    |                ########
########                -------------------------------                ########
########                                                               ########
###############################################################################
"
leo run place_bid aleo12c9k0m53r5yjq7zg4dpdgglepp6axmv83tw7ndku7t0ftckajcxqc00aka 3u64 || exit

# Swap in the private key and address of the auctioneer to .env.
echo "
NETWORK=testnet
PRIVATE_KEY=APrivateKey1zAUCTIONEER....
ENDPOINT=https://localhost:3030
" > .env

# Have the auctioneer select the winning bid.
echo "
###############################################################################
########                                                               ########
########       STEP 3: The auctioneer selects the winning bidder       ########
########                                                               ########
########                -------------------------------                ########
########                |  OPEN   |    B    |  → A ←  |                ########
########                -------------------------------                ########
########                |   Bid   |   3    |  → 10 ← |                ########
########                -------------------------------                ########
########                                                               ########
###############################################################################
"
leo run resolve "{
  owner: aleo1f9rwrqkpng27xmuf630xuup479mcyl6etnzwu74v3329jg06zcxq7wktzl.private,
  bidder: aleo1ashyu96tjwe63u0gtnnv8z5lhapdu4l5pjsl2kha7fv7hvz2eqxs5dz0rg.private,
  amount: 10u64.private,
  is_winner: false.private,
  _nonce: 7550506099450396963529170486105398877861043700129885431947219994110284082348group.public
}" "{
  owner: aleo1f9rwrqkpng27xmuf630xuup479mcyl6etnzwu74v3329jg06zcxq7wktzl.private,
  bidder: aleo12c9k0m53r5yjq7zg4dpdgglepp6axmv83tw7ndku7t0ftckajcxqc00aka.private,
  amount: 3u64.private,
  is_winner: false.private,
  _nonce: 7995426368263876317438977593766293982432009653349601309641862677948971356700group.public
}" || exit

# Have the auctioneer finish the auction.
echo "
###############################################################################
########                                                               ########
########         STEP 4: The auctioneer completes the auction.         ########
########                                                               ########
########                -------------------------------                ########
########                |  CLOSE  |    B    |  → A ←  |                ########
########                -------------------------------                ########
########                |   Bid   |   3    |  → 10 ← |                ########
########                -------------------------------                ########
########                                                               ########
###############################################################################
"
leo run finish "{
  owner: aleo1f9rwrqkpng27xmuf630xuup479mcyl6etnzwu74v3329jg06zcxq7wktzl.private,
  bidder: aleo1ashyu96tjwe63u0gtnnv8z5lhapdu4l5pjsl2kha7fv7hvz2eqxs5dz0rg.private,
  amount: 10u64.private,
  is_winner: true.private,
  _nonce: 7550506099450396963529170486105398877861043700129885431947219994110284082348group.public
}" || exit


# Restore the .env file to its original state.
echo "
NETWORK=testnet
PRIVATE_KEY=APrivateKey1zAUCTIONEER...
ENDPOINT=https://localhost:3030
" > .env