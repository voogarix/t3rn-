#!/bin/bash
# Colors
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${RED}Join our Telegram channel: https://t.me/kriptoqapik${NC}"
echo -e "${BLUE}-----------------------------------------------------${NC}"
echo -e "${RED}Get free 20€ credit for VPS on Hetzner: https://hetzner.cloud/?ref=mjjaxNOJxUW1${NC}"
sleep 5

# Step 0: Clean up previous installations
echo "Cleaning up previous installations..."
if [ -d "t3rn" ]; then
    echo "Deleting existing t3rn directory..."
    rm -rf t3rn
fi

if [ -d "executor" ]; then
    echo "Deleting existing executor directory..."
    rm -rf executor
fi

if ls executor-linux-*.tar.gz 1> /dev/null 2>&1; then
    echo "Deleting previously downloaded tar.gz files..."
    rm -f executor-linux-*.tar.gz
fi

# Step 1: Create and navigate to t3rn directory
echo "Creating and navigating to t3rn directory..."
mkdir -p t3rn
cd t3rn || { echo "Failed to create or navigate to t3rn directory. Exiting."; exit 1; }

# Step 2: Download the latest release
echo "Downloading the latest release..."
LATEST_TAG=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
if [ -z "$LATEST_TAG" ]; then
    echo "Failed to fetch the latest release tag. Please check your internet connection and try again."
    exit 1
fi

DOWNLOAD_URL="https://github.com/t3rn/executor-release/releases/download/$LATEST_TAG/executor-linux-$LATEST_TAG.tar.gz"
wget "$DOWNLOAD_URL" -O "executor-linux-$LATEST_TAG.tar.gz"
if [ $? -ne 0 ]; then
    echo "Failed to download the latest release. Please check the URL and try again."
    exit 1
fi
echo "Download complete."

# Step 3: Extract the archive (with visible extraction process)
echo "Extracting the archive..."
tar -xvzf "executor-linux-$LATEST_TAG.tar.gz"
if [ $? -ne 0 ]; then
    echo "Failed to extract the archive. Please check the file and try again."
    exit 1
fi
echo "Extraction complete."

# Step 4: Navigate to the executor binary location
echo "Navigating to the executor binary location..."
mkdir -p executor/executor/bin
cd executor/executor/bin || { echo "Failed to navigate to executor binary location. Exiting."; exit 1; }

# Function to ask for user input
ask_for_input() {
    local prompt="$1"
    local input

    read -p "$prompt: " input
    echo "$input"
}

# Function to validate gas value
validate_gas_value() {
    local gas_value="$1"
    
    # Check if the input is an integer
    if [[ ! "$gas_value" =~ ^[0-9]+$ ]]; then
        echo "Error: Gas value must be an integer."
        return 1
    fi

    # Check if the gas value is within the allowed range
    if (( gas_value < 100 || gas_value > 20000 )); then
        echo "Error: Gas value must be between 100 and 20000."
        return 1
    fi

    return 0
}

# Ask if the user wants to run an API node or RPC node
read -p "Do you want to run an API node or RPC node? (api/rpc): " NODE_TYPE
if [[ "$NODE_TYPE" != "api" && "$NODE_TYPE" != "rpc" ]]; then
    echo "Invalid input. Please enter 'api' or 'rpc'. Exiting."
    exit 1
fi

# Ask for wallet private key (visible input)
WALLET_PRIVATE_KEY=$(ask_for_input "Enter your wallet private key")

# Ask for gas value and validate it
while true; do
    GAS_VALUE=$(ask_for_input "Enter the gas value (must be an integer between 100 and 20000)")
    if validate_gas_value "$GAS_VALUE"; then
        break
    fi
done

# Set Node Environment
export NODE_ENV=testnet

# Set log settings
export LOG_LEVEL=debug
export LOG_PRETTY=false

# Process bids, orders, and claims
export EXECUTOR_PROCESS_BIDS_ENABLED=true
export EXECUTOR_PROCESS_ORDERS_ENABLED=true
export EXECUTOR_PROCESS_CLAIMS_ENABLED=true

# Configure API-specific settings based on node type
if [[ "$NODE_TYPE" == "api" ]]; then
    # Automatically enable API-related settings for API nodes
    export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=true
    export EXECUTOR_PROCESS_ORDERS_API_ENABLED=true
else
    # Automatically disable API-related settings for RPC nodes
    export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
    export EXECUTOR_PROCESS_ORDERS_API_ENABLED=false
fi

# Default RPC endpoints
DEFAULT_RPC_ENDPOINTS_ARBT="https://arbitrum-sepolia-rpc.publicnode.com"
DEFAULT_RPC_ENDPOINTS_BSSP="https://sepolia.base.org"
DEFAULT_RPC_ENDPOINTS_BLSS="https://sepolia.blast.io"
DEFAULT_RPC_ENDPOINTS_OPSP="https://sepolia.optimism.io"
DEFAULT_RPC_ENDPOINTS_L1RN="https://brn.calderarpc.com/http,https://brn.rpc.caldera.xyz/"

# Ask if the user wants to add custom RPC endpoints or use default ones
read -p "Do you want to add custom public RPC endpoints? (y/n): " CUSTOM_RPC
if [[ "$CUSTOM_RPC" =~ ^[Yy]$ ]]; then
    echo "Enter custom RPC endpoints (comma-separated for multiple endpoints):"
    RPC_ENDPOINTS_ARBT=$(ask_for_input "Arbitrum Sepolia RPC endpoints (default: $DEFAULT_RPC_ENDPOINTS_ARBT)")
    RPC_ENDPOINTS_BSSP=$(ask_for_input "Base Sepolia RPC endpoints (default: $DEFAULT_RPC_ENDPOINTS_BSSP)")
    RPC_ENDPOINTS_BLSS=$(ask_for_input "Blast Sepolia RPC endpoints (default: $DEFAULT_RPC_ENDPOINTS_BLSS)")
    RPC_ENDPOINTS_OPSP=$(ask_for_input "Optimism Sepolia RPC endpoints (default: $DEFAULT_RPC_ENDPOINTS_OPSP)")

    # Use default values if the user leaves the input blank
    RPC_ENDPOINTS_ARBT=${RPC_ENDPOINTS_ARBT:-$DEFAULT_RPC_ENDPOINTS_ARBT}
    RPC_ENDPOINTS_BSSP=${RPC_ENDPOINTS_BSSP:-$DEFAULT_RPC_ENDPOINTS_BSSP}
    RPC_ENDPOINTS_BLSS=${RPC_ENDPOINTS_BLSS:-$DEFAULT_RPC_ENDPOINTS_BLSS}
    RPC_ENDPOINTS_OPSP=${RPC_ENDPOINTS_OPSP:-$DEFAULT_RPC_ENDPOINTS_OPSP}
else
    # Use default RPC endpoints
    RPC_ENDPOINTS_ARBT=$DEFAULT_RPC_ENDPOINTS_ARBT
    RPC_ENDPOINTS_BSSP=$DEFAULT_RPC_ENDPOINTS_BSSP
    RPC_ENDPOINTS_BLSS=$DEFAULT_RPC_ENDPOINTS_BLSS
    RPC_ENDPOINTS_OPSP=$DEFAULT_RPC_ENDPOINTS_OPSP
fi

# Always use default L1RN RPC endpoints (no custom option)
RPC_ENDPOINTS_L1RN=$DEFAULT_RPC_ENDPOINTS_L1RN

# Configure RPC endpoints based on node type
if [[ "$NODE_TYPE" == "rpc" ]]; then
    # Ask for Alchemy API key for RPC node
    ALCHEMY_API_KEY=$(ask_for_input "Enter your Alchemy API key")
    RPC_ENDPOINTS_ARBT="https://arb-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY,$RPC_ENDPOINTS_ARBT"
    RPC_ENDPOINTS_BSSP="https://base-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY,$RPC_ENDPOINTS_BSSP"
    RPC_ENDPOINTS_BLSS="https://blast-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY,$RPC_ENDPOINTS_BLSS"
    RPC_ENDPOINTS_OPSP="https://opt-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY,$RPC_ENDPOINTS_OPSP"
fi

# ASK FOR WALLET PRIVATE KEY
export PRIVATE_KEY_LOCAL=$WALLET_PRIVATE_KEY
export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,blast-sepolia,optimism-sepolia,l1rn'

# Export RPC endpoints
export RPC_ENDPOINTS_ARBT
export RPC_ENDPOINTS_BSSP
export RPC_ENDPOINTS_BLSS
export RPC_ENDPOINTS_OPSP
export RPC_ENDPOINTS_L1RN
export EXECUTOR_MAX_L3_GAS_PRICE=$GAS_VALUE

# Ask if the user wants to switch to advanced mode
read -p "Do you want to switch to advanced mode? (y/n): " ADVANCED_MODE
if [[ "$ADVANCED_MODE" =~ ^[Yy]$ ]]; then
    echo -e "\nAdvanced mode enabled. You will now configure additional flags."

    # Advanced flags with explanations
    echo -e "\n1. Enable Arbitrage Strategy: Determines whether the arbitrage strategy is enabled."
    read -p "Enable Arbitrage Strategy? (true/false): " EXECUTOR_ENABLE_ARBITRAGE_STRATEGY
    export EXECUTOR_ENABLE_ARBITRAGE_STRATEGY=${EXECUTOR_ENABLE_ARBITRAGE_STRATEGY:-false}

    echo -e "\n2. Halt Based on Ratio: Determines whether the executor should halt based on a specific ratio (e.g., gas price ratio)."
    read -p "Enable Halt Based on Ratio? (true/false): " EXECUTOR_HALT_BASED_ON_RATIO
    export EXECUTOR_HALT_BASED_ON_RATIO=${EXECUTOR_HALT_BASED_ON_RATIO:-false}

    echo -e "\n3. Enable Bidding Processing: Enables or disables bidding processing."
    read -p "Enable Bidding Processing? (true/false): " EXECUTOR_ENABLE_BIDDING_PROCESSING
    export EXECUTOR_ENABLE_BIDDING_PROCESSING=${EXECUTOR_ENABLE_BIDDING_PROCESSING:-false}

    echo -e "\n4. Enable Batch Bidding: Enables or disables batch bidding."
    read -p "Enable Batch Bidding? (true/false): " EXECUTOR_ENABLE_BATCH_BIDDING
    export EXECUTOR_ENABLE_BATCH_BIDDING=${EXECUTOR_ENABLE_BATCH_BIDDING:-true}

    echo -e "\n5. Skip Claim Gas Estimate: Determines whether the executor should skip gas estimation for claims."
    read -p "Skip Claim Gas Estimate? (true/false): " EXECUTOR_SKIP_CLAIM_GAS_ESTIMATE
    export EXECUTOR_SKIP_CLAIM_GAS_ESTIMATE=${EXECUTOR_SKIP_CLAIM_GAS_ESTIMATE:-true}

    echo -e "\n6. Skip Revert Book Checks: Determines whether the executor should skip revert book checks."
    read -p "Skip Revert Book Checks? (true/false): " EXECUTOR_SKIP_REVERT_BOOK_CHECKS
    export EXECUTOR_SKIP_REVERT_BOOK_CHECKS=${EXECUTOR_SKIP_REVERT_BOOK_CHECKS:-true}

    echo -e "\n7. Batch Execute Transmit: Enables or disables batch execution and transmission of transactions."
    read -p "Enable Batch Execute Transmit? (true/false): " EXECUTOR_BATCH_EXECUTE_TRANSMIT
    export EXECUTOR_BATCH_EXECUTE_TRANSMIT=${EXECUTOR_BATCH_EXECUTE_TRANSMIT:-true}

    echo -e "\n8. Resend Failed Claims: Determines whether the executor should resend failed claims."
    read -p "Resend Failed Claims? (true/false): " EXECUTOR_RESEND_FAILED_CLAIMS
    export EXECUTOR_RESEND_FAILED_CLAIMS=${EXECUTOR_RESEND_FAILED_CLAIMS:-false}

    echo -e "\n9. Ad Hoc Execute: Enables or disables ad-hoc execution of transactions."
    read -p "Enable Ad Hoc Execute? (true/false): " EXECUTOR_AD_HOC_EXECUTE
    export EXECUTOR_AD_HOC_EXECUTE=${EXECUTOR_AD_HOC_EXECUTE:-true}

    echo -e "\n10. Min Balance Threshold ETH: Sets the minimum balance threshold (in ETH) required for the executor to operate."
    read -p "Enter Min Balance Threshold ETH (default: 0.1): " EXECUTOR_MIN_BALANCE_THRESHOLD_ETH
    export EXECUTOR_MIN_BALANCE_THRESHOLD_ETH=${EXECUTOR_MIN_BALANCE_THRESHOLD_ETH:-0.1}

    echo -e "\n11. Batch Size: Sets the size of batches for processing transactions."
    read -p "Enter Batch Size (default: 10): " BATCH_SIZE
    export BATCH_SIZE=${BATCH_SIZE:-10}

    echo -e "\n12. Batch Creation Timeout Sec: Sets the timeout (in seconds) for batch creation."
    read -p "Enter Batch Creation Timeout Sec (default: 3): " BATCH_CREATION_TIMEOUT_SEC
    export BATCH_CREATION_TIMEOUT_SEC=${BATCH_CREATION_TIMEOUT_SEC:-3}

    echo -e "\n13. Bid Decrease Factor: Sets the factor by which bids are decreased."
    read -p "Enter Bid Decrease Factor (default: 1000000): " BID_DECREASE_FACTOR
    export BID_DECREASE_FACTOR=${BID_DECREASE_FACTOR:-1000000}

    echo -e "\n14. Bid Decrease Percent: Sets the percentage by which bids are decreased."
    read -p "Enter Bid Decrease Percent (default: 10): " BID_DECREASE_PERCENT
    export BID_DECREASE_PERCENT=${BID_DECREASE_PERCENT:-10}

    echo -e "\n15. Arbitrage Strategy: Configures the arbitrage strategy as a JSON object."
    read -p "Enter Arbitrage Strategy (JSON format, leave blank for default): " ARBITRAGE_STRATEGY
    export ARBITRAGE_STRATEGY=${ARBITRAGE_STRATEGY:-"{}"}
fi

# Display the collected inputs and settings (for verification)
echo -e "\nCollected inputs and settings:"
echo "Node Type: $NODE_TYPE"
if [[ "$NODE_TYPE" == "rpc" ]]; then
    echo "Alchemy API Key: $ALCHEMY_API_KEY"
fi
echo "Wallet Private Key: $WALLET_PRIVATE_KEY"
echo "Gas Value: $GAS_VALUE"
echo "EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API: $EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API"
echo "EXECUTOR_PROCESS_ORDERS_API_ENABLED: $EXECUTOR_PROCESS_ORDERS_API_ENABLED"
echo "NODE_ENV: $NODE_ENV"
echo "LOG_LEVEL: $LOG_LEVEL"
echo "LOG_PRETTY: $LOG_PRETTY"
echo "EXECUTOR_PROCESS_BIDS_ENABLED: $EXECUTOR_PROCESS_BIDS_ENABLED"
echo "EXECUTOR_PROCESS_ORDERS_ENABLED: $EXECUTOR_PROCESS_ORDERS_ENABLED"
echo "EXECUTOR_PROCESS_CLAIMS_ENABLED: $EXECUTOR_PROCESS_CLAIMS_ENABLED"
echo "RPC Endpoints:"
echo "ARBT: $RPC_ENDPOINTS_ARBT"
echo "BSSP: $RPC_ENDPOINTS_BSSP"
echo "BLSS: $RPC_ENDPOINTS_BLSS"
echo "OPSP: $RPC_ENDPOINTS_OPSP"
echo "L1RN: $RPC_ENDPOINTS_L1RN"

if [[ "$ADVANCED_MODE" =~ ^[Yy]$ ]]; then
    echo -e "\nAdvanced Settings:"
    echo "EXECUTOR_ENABLE_ARBITRAGE_STRATEGY: $EXECUTOR_ENABLE_ARBITRAGE_STRATEGY"
    echo "EXECUTOR_HALT_BASED_ON_RATIO: $EXECUTOR_HALT_BASED_ON_RATIO"
    echo "EXECUTOR_ENABLE_BIDDING_PROCESSING: $EXECUTOR_ENABLE_BIDDING_PROCESSING"
    echo "EXECUTOR_ENABLE_BATCH_BIDDING: $EXECUTOR_ENABLE_BATCH_BIDDING"
    echo "EXECUTOR_SKIP_CLAIM_GAS_ESTIMATE: $EXECUTOR_SKIP_CLAIM_GAS_ESTIMATE"
    echo "EXECUTOR_SKIP_REVERT_BOOK_CHECKS: $EXECUTOR_SKIP_REVERT_BOOK_CHECKS"
    echo "EXECUTOR_BATCH_EXECUTE_TRANSMIT: $EXECUTOR_BATCH_EXECUTE_TRANSMIT"
    echo "EXECUTOR_RESEND_FAILED_CLAIMS: $EXECUTOR_RESEND_FAILED_CLAIMS"
    echo "EXECUTOR_AD_HOC_EXECUTE: $EXECUTOR_AD_HOC_EXECUTE"
    echo "EXECUTOR_MIN_BALANCE_THRESHOLD_ETH: $EXECUTOR_MIN_BALANCE_THRESHOLD_ETH"
    echo "BATCH_SIZE: $BATCH_SIZE"
    echo "BATCH_CREATION_TIMEOUT_SEC: $BATCH_CREATION_TIMEOUT_SEC"
    echo "BID_DECREASE_FACTOR: $BID_DECREASE_FACTOR"
    echo "BID_DECREASE_PERCENT: $BID_DECREASE_PERCENT"
    echo "ARBITRAGE_STRATEGY: $ARBITRAGE_STRATEGY"
fi

# Step 5: Proceed with the installation or other setup steps
echo -e "\nIf this script helped you, dont forget to give a ⭐ on github 😉..."
sleep 5
echo -e "\nRunning the node..."
./executor
