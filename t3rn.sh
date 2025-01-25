#!/bin/bash
# Colors
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${RED}Join our Telegram channel: https://t.me/kriptoqapik${NC}"
echo -e "${BLUE}-----------------------------------------------------${NC}"
echo -e "${RED}Get free 20€ credit for VPS on Hetzner: https://hetzner.cloud/?ref=mjjaxNOJxUW1${NC}"
sleep 5

# Delete old executor file if any
echo
echo -e "Deleting Previous Version "
rm -r executor-linux-*
rm -rf t3rn*
sleep 3
echo -e "Downloading the latest version of executor"
echo
mkdir -p t3rn
cd $HOME/t3rn

# Download the latest release of executor
curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | \
grep -Po '"tag_name": "\K.*?(?=")' | \
xargs -I {} wget https://github.com/t3rn/executor-release/releases/download/{}/executor-linux-{}.tar.gz
# Extracting archives
tar -xzf executor-linux-*.tar.gz

# Move to the binary executor directory
cd $HOME/t3rn/executor/executor/bin || { echo "Directory not found!"; exit 1; }

# Request manual input for PRIVATE_KEY_LOCAL
echo -n "Enter PRIVATE KEY: "
read PRIVATE_KEY_LOCAL  # Input is visible as it is typed
echo "Your PRIVATE KEY: $PRIVATE_KEY_LOCAL"

# Request manual input for ACLHEMY RPC API
echo -n "Enter ALCHEMY API: "
read KEYALCHEMY  # Input is visible as it is typed

# Check if KEYALCHEMY is empty
if [ -z "$KEYALCHEMY" ]; then
  echo "ALCHEMY API KEY is empty, bypassing the RPC endpoint configuration for Alchemy."
else
  echo "Your ALCHEMY API KEY: $KEYALCHEMY"
  export RPC_ENDPOINTS_ARBT="https://arb-sepolia.g.alchemy.com/v2/$KEYALCHEMY,https://arbitrum-sepolia-rpc.publicnode.com"
  export RPC_ENDPOINTS_BSSP="https://base-sepolia.g.alchemy.com/v2/$KEYALCHEMY,https://sepolia.base.org"
  export RPC_ENDPOINTS_BLSS="https://blast-sepolia.g.alchemy.com/v2/$KEYALCHEMY,https://sepolia.blast.io"
  export RPC_ENDPOINTS_OPSP="https://opt-sepolia.g.alchemy.com/v2/$KEYALCHEMY,https://sepolia.optimism.io"
fi

# Requesting manual input for EXECUTOR_MAX_L3_GAS_PRICE
echo -n "Enter max GAS (Default is 200): "
read EXECUTOR_MAX_L3_GAS_PRICE

# If not filled, use the default value of 200.
if [ -z "$EXECUTOR_MAX_L3_GAS_PRICE" ]; then
  EXECUTOR_MAX_L3_GAS_PRICE=200
fi

echo "GAS PRICE used: $EXECUTOR_MAX_L3_GAS_PRICE"

# Setting up environment variables
export NODE_ENV=testnet
export LOG_LEVEL=debug
export LOG_PRETTY=false
export EXECUTOR_PROCESS_ORDERS=true
export EXECUTOR_PROCESS_CLAIMS=true
export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,blast-sepolia,optimism-sepolia,l1rn'
export PRIVATE_KEY_LOCAL="$PRIVATE_KEY_LOCAL"
export EXECUTOR_MAX_L3_GAS_PRICE="$EXECUTOR_MAX_L3_GAS_PRICE"
export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
export EXECUTOR_PROCESS_ORDERS_API_ENABLED=false
export RPC_ENDPOINTS_L1RN='https://brn.rpc.caldera.xyz/,https://brn.calderarpc.com/http'
export EXECUTOR_ENABLE_BATCH_BIDDING=true
export EXECUTOR_PROCESS_BIDS_ENABLED=true

# Launching executor
echo -e "Running executor with current configuration..."
sleep 2
./executor
