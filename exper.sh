#!/bin/bash
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${RED}Join our Telegram channel: https://t.me/kriptoqapik${NC}"
echo -e "${BLUE}-----------------------------------------------------${NC}"
echo -e "${RED}Get free 20€ credit for VPS on Hetzner: https://hetzner.cloud/?ref=mjjaxNOJxUW1${NC}"
sleep 5

# Log file for debugging
LOG_FILE="setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Function to display usage instructions
usage() {
    echo -e "${GREEN}Usage: $0 [--verbose] [--dry-run]${NC}"
    echo -e "${GREEN}  --verbose: Enable verbose logging for debugging.${NC}"
    echo -e "${GREEN}  --dry-run: Simulate script execution without making changes.${NC}"
    exit 0
}

# Parse command-line arguments
VERBOSE=false
DRY_RUN=false
for arg in "$@"; do
    case "$arg" in
        --verbose)
            VERBOSE=true
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown argument: $arg${NC}"
            usage
            ;;
    esac
done

# Enable verbose mode if requested
if $VERBOSE; then
    set -x
fi

# Dry-run mode message
if $DRY_RUN; then
    echo -e "${BLUE}Dry-run mode enabled. No changes will be made.${NC}"
fi

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
        echo -e "${RED}Error: Gas value must be an integer.${NC}"
        return 1
    fi

    # Check if the gas value is within the allowed range
    if (( gas_value < 100 || gas_value > 20000 )); then
        echo -e "${RED}Error: Gas value must be between 100 and 20000.${NC}"
        return 1
    fi

    return 0
}

# Language selection
echo -e "${GREEN}Select your language / Dil seçin / Выберите язык / Wählen Sie Ihre Sprache / Pilih bahasa Anda / Choisissez votre langue:${NC}"
echo "English (en)"
echo "Azerbaijani (az)"
echo "Russian (ru)"
echo "German (de)"
echo "Indonesian (id)"
echo "French (fr)"
read -p "Enter language code (e.g., en, az, ru, de, id, fr): " LANG_CODE

# Language-specific strings
case "$LANG_CODE" in
    en)
        MSG_CLEANUP="Cleaning up previous installations..."
        MSG_DOWNLOAD="Downloading the latest release..."
        MSG_EXTRACT="Extracting the archive..."
        MSG_INVALID_INPUT="Invalid input. Please enter 'api' or 'rpc'. Exiting."
        MSG_PRIVATE_KEY="Enter your wallet private key"
        MSG_GAS_VALUE="Enter the gas value (must be an integer between 100 and 20000)"
        MSG_INVALID_GAS="Error: Gas value must be between 100 and 20000."
        MSG_NODE_TYPE="Do you want to run an API node or RPC node? (api/rpc)"
        MSG_RPC_ENDPOINTS="Do you want to add custom public RPC endpoints? (y/n)"
        MSG_THANKS="If this script helped you, don't forget to give a ⭐ on GitHub 😉..."
        MSG_NETWORK_SELECTION="Select networks to enable (comma-separated, e.g., ARBT,BSSP,OPSP,BLSS):"
        MSG_NETWORK_SELECTION_DETAILS="Available networks:\n- arbitrum-sepolia (type ARBT to enable)\n- base-sepolia (type BSSP to enable)\n- optimism-sepolia (type OPSP to enable)\n- blast-sepolia (type BLSS to enable)\nL1RN is always enabled.\nType ALL to enable all networks"
        ;;
    az)
        MSG_CLEANUP="Əvvəlki quraşdırmaları təmizləyirəm..."
        MSG_DOWNLOAD="Son buraxılışı yükləyirəm..."
        MSG_EXTRACT="Arxiv açılır..."
        MSG_INVALID_INPUT="Yanlış giriş. 'api' və ya 'rpc' daxil edin. Çıxılır."
        MSG_PRIVATE_KEY="Cüzdanınızın gizli açarını daxil edin"
        MSG_GAS_VALUE="Qaz dəyərini daxil edin (100 ilə 20000 arasında tam ədəd olmalıdır)"
        MSG_INVALID_GAS="Xəta: Qaz dəyəri 100 ilə 20000 arasında olmalıdır."
        MSG_NODE_TYPE="API node və ya RPC node işlətmək istəyirsiniz? (api/rpc)"
        MSG_RPC_ENDPOINTS="Xüsusi RPC endpointləri əlavə etmək istəyirsiniz? (y/n)"
        MSG_THANKS="Bu skript sizə kömək etdisə, GitHub-da ⭐ verməyi unutmayın 😉..."
        MSG_NETWORK_SELECTION="Aktivləşdirmək üçün şəbəkələri seçin (vergüllə ayrılmış, məsələn, ARBT,BSSP,OPSP,BLSS):"
        MSG_NETWORK_SELECTION_DETAILS="Mövcud şəbəkələr:\n- arbitrum-sepolia (aktivləşdirmək üçün ARBT yazın)\n- base-sepolia (aktivləşdirmək üçün BSSP yazın)\n- optimism-sepolia (aktivləşdirmək üçün OPSP yazın)\n- blast-sepolia (aktivləşdirmək üçün BLSS yazın)\nL1RN həmişə aktivdir.\nBütün şəbəkələi aktiv etmək üçün ALL yazın "
        ;;
    ru)
        MSG_CLEANUP="Очистка предыдущих установок..."
        MSG_DOWNLOAD="Загрузка последнего релиза..."
        MSG_EXTRACT="Распаковка архива..."
        MSG_INVALID_INPUT="Неверный ввод. Пожалуйста, введите 'api' или 'rpc'. Выход."
        MSG_PRIVATE_KEY="Введите ваш приватный ключ кошелька"
        MSG_GAS_VALUE="Введите значение газа (должно быть целым числом от 100 до 20000)"
        MSG_INVALID_GAS="Ошибка: Значение газа должно быть от 100 до 20000."
        MSG_NODE_TYPE="Вы хотите запустить API-узел или RPC-узел? (api/rpc)"
        MSG_RPC_ENDPOINTS="Хотите добавить пользовательские RPC-точки? (y/n)"
        MSG_THANKS="Если этот скрипт помог вам, не забудьте поставить ⭐ на GitHub 😉..."
        MSG_NETWORK_SELECTION="Выберите сети для включения (через запятую, например, ARBT,BSSP,OPSP,BLSS):"
        MSG_NETWORK_SELECTION_DETAILS="Доступные сети:\n- arbitrum-sepolia (введите ARBT для включения)\n- base-sepolia (введите BSSP для включения)\n- optimism-sepolia (введите OPSP для включения)\n- blast-sepolia (введите BLSS для включения)\nL1RN всегда включен.\nВведите ALL, чтобы включить все сети."
        ;;
    de)
        MSG_CLEANUP="Vorherige Installationen werden bereinigt..."
        MSG_DOWNLOAD="Die neueste Version wird heruntergeladen..."
        MSG_EXTRACT="Das Archiv wird entpackt..."
        MSG_INVALID_INPUT="Ungültige Eingabe. Bitte geben Sie 'api' oder 'rpc' ein. Beenden."
        MSG_PRIVATE_KEY="Geben Sie Ihren privaten Wallet-Schlüssel ein"
        MSG_GAS_VALUE="Geben Sie den Gas-Wert ein (muss eine ganze Zahl zwischen 100 und 20000 sein)"
        MSG_INVALID_GAS="Fehler: Der Gas-Wert muss zwischen 100 und 20000 liegen."
        MSG_NODE_TYPE="Möchten Sie einen API-Knoten oder RPC-Knoten ausführen? (api/rpc)"
        MSG_RPC_ENDPOINTS="Möchten Sie benutzerdefinierte RPC-Endpoints hinzufügen? (y/n)"
        MSG_THANKS="Wenn Ihnen dieses Skript geholfen hat, vergessen Sie nicht, auf GitHub einen ⭐ zu hinterlassen 😉..."
        MSG_NETWORK_SELECTION="Wählen Sie die zu aktivierenden Netzwerke aus (durch Kommas getrennt, z.B. ARBT,BSSP,OPSP,BLSS):"
        MSG_NETWORK_SELECTION_DETAILS="Verfügbare Netzwerke:\n- arbitrum-sepolia (geben Sie ARBT ein, um es zu aktivieren)\n- base-sepolia (geben Sie BSSP ein, um es zu aktivieren)\n- optimism-sepolia (geben Sie OPSP ein, um es zu aktivieren)\n- blast-sepolia (geben Sie BLSS ein, um es zu aktivieren)\nL1RN ist immer aktiviert.\nGeben Sie ALL ein, um alle Netzwerke zu aktivieren"
        ;;
    id)
        MSG_CLEANUP="Membersihkan instalasi sebelumnya..."
        MSG_DOWNLOAD="Mengunduh rilis terbaru..."
        MSG_EXTRACT="Mengekstrak arsip..."
        MSG_INVALID_INPUT="Input tidak valid. Masukkan 'api' atau 'rpc'. Keluar."
        MSG_PRIVATE_KEY="Masukkan kunci pribadi dompet Anda"
        MSG_GAS_VALUE="Masukkan nilai gas (harus bilangan bulat antara 100 dan 20000)"
        MSG_INVALID_GAS="Kesalahan: Nilai gas harus antara 100 dan 20000."
        MSG_NODE_TYPE="Apakah Anda ingin menjalankan node API atau node RPC? (api/rpc)"
        MSG_RPC_ENDPOINTS="Apakah Anda ingin menambahkan endpoint RPC kustom? (y/n)"
        MSG_THANKS="Jika skrip ini membantu Anda, jangan lupa beri ⭐ di GitHub 😉..."
        MSG_NETWORK_SELECTION="Pilih jaringan yang akan diaktifkan (dipisahkan koma, misalnya, ARBT,BSSP,OPSP,BLSS):"
        MSG_NETWORK_SELECTION_DETAILS="Jaringan yang tersedia:\n- arbitrum-sepolia (ketik ARBT untuk mengaktifkan)\n- base-sepolia (ketik BSSP untuk mengaktifkan)\n- optimism-sepolia (ketik OPSP untuk mengaktifkan)\n- blast-sepolia (ketik BLSS untuk mengaktifkan)\nL1RN selalu diaktifkan.\nKetik ALL untuk mengaktifkan semua jaringan"
        ;;
    fr)
        MSG_CLEANUP="Nettoyage des installations précédentes..."
        MSG_DOWNLOAD="Téléchargement de la dernière version..."
        MSG_EXTRACT="Extraction de l'archive..."
        MSG_INVALID_INPUT="Entrée invalide. Veuillez entrer 'api' ou 'rpc'. Sortie."
        MSG_PRIVATE_KEY="Entrez votre clé privée de portefeuille"
        MSG_GAS_VALUE="Entrez la valeur du gaz (doit être un entier entre 100 et 20000)"
        MSG_INVALID_GAS="Erreur : La valeur du gaz doit être comprise entre 100 et 20000."
        MSG_NODE_TYPE="Voulez-vous exécuter un nœud API ou un nœud RPC ? (api/rpc)"
        MSG_RPC_ENDPOINTS="Voulez-vous ajouter des points de terminaison RPC personnalisés ? (y/n)"
        MSG_THANKS="Si ce script vous a aidé, n'oubliez pas de mettre un ⭐ sur GitHub 😉..."
        MSG_NETWORK_SELECTION="Sélectionnez les réseaux à activer (séparés par des virgules, par exemple, ARBT,BSSP,OPSP,BLSS):"
        MSG_NETWORK_SELECTION_DETAILS="Réseaux disponibles:\n- arbitrum-sepolia (tapez ARBT pour activer)\n- base-sepolia (tapez BSSP pour activer)\n- optimism-sepolia (tapez OPSP pour activer)\n- blast-sepolia (tapez BLSS pour activer)\nL1RN est toujours activé.\nTapez ALL pour activer tous les réseaux"
        ;;
    *)
        echo -e "${RED}Invalid language code. Exiting.${NC}"
        exit 1
        ;;
esac

# Step 0: Clean up previous installations
echo -e "${BLUE}$MSG_CLEANUP${NC}"
if $DRY_RUN; then
    echo -e "${GREEN}[Dry-run] Would delete existing t3rn and executor directories.${NC}"
else
    if [ -d "t3rn" ]; then
        echo "Deleting existing t3rn directory..."
        rm -rf t3rn
    fi

    if [ -d "executor" ]; then
        echo "Deleting existing executor directory..."
        rm -rf executor
    fi
	
	if ls setup.log 1> /dev/null 2>&1; then
        echo "Deleting previously downloaded tar.gz files..."
        rm -f setup.log
    fi

    if ls executor-linux-*.tar.gz 1> /dev/null 2>&1; then
        echo "Deleting previously downloaded tar.gz files..."
        rm -f executor-linux-*.tar.gz
    fi
fi

# Step 1: Create and navigate to t3rn directory
echo -e "${BLUE}Creating and navigating to t3rn directory...${NC}"
if $DRY_RUN; then
    echo -e "${GREEN}[Dry-run] Would create and navigate to t3rn directory.${NC}"
else
    mkdir -p t3rn
    cd t3rn || { echo -e "${RED}Failed to create or navigate to t3rn directory. Exiting.${NC}"; exit 1; }
fi

# Step 2: Download the latest release
echo -e "${BLUE}$MSG_DOWNLOAD${NC}"
LATEST_TAG=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
if [ -z "$LATEST_TAG" ]; then
    echo -e "${RED}Failed to fetch the latest release tag. Please check your internet connection and try again.${NC}"
    exit 1
fi

DOWNLOAD_URL="https://github.com/t3rn/executor-release/releases/download/$LATEST_TAG/executor-linux-$LATEST_TAG.tar.gz"
wget "$DOWNLOAD_URL" -O "executor-linux-$LATEST_TAG.tar.gz"
if [ $? -ne 0 ]; then
    echo "Failed to download the latest release. Please check the URL and try again."
    exit 1
fi
echo "Download complete."

# Step 3: Extract the archive
echo -e "${BLUE}$MSG_EXTRACT${NC}"
tar -xvzf "executor-linux-$LATEST_TAG.tar.gz"
if [ $? -ne 0 ]; then
    echo "Failed to extract the archive. Please check the file and try again."
    exit 1
fi
echo "Extraction complete."

# Step 4: Navigate to the executor binary location
echo -e "${BLUE}Navigating to the executor binary location...${NC}"
if $DRY_RUN; then
    echo -e "${GREEN}[Dry-run] Would navigate to executor binary location.${NC}"
else
    mkdir -p executor/executor/bin
    cd executor/executor/bin || { echo -e "${RED}Failed to navigate to executor binary location. Exiting.${NC}"; exit 1; }
fi

# Ask if the user wants to run an API node or RPC node
read -p "$MSG_NODE_TYPE: " NODE_TYPE
if [[ "$NODE_TYPE" != "api" && "$NODE_TYPE" != "rpc" ]]; then
    echo -e "${RED}$MSG_INVALID_INPUT${NC}"
    exit 1
fi

# Ask for wallet private key (visible input)
WALLET_PRIVATE_KEY=$(ask_for_input "$MSG_PRIVATE_KEY")

# Ask for gas value and validate it
while true; do
    GAS_VALUE=$(ask_for_input "$MSG_GAS_VALUE")
    if validate_gas_value "$GAS_VALUE"; then
        break
    fi
done

if [[ "$NETWORK_SELECTION" == "ALL" ]]; then
    ENABLED_NETWORKS="l1rn,arbitrum-sepolia,base-sepolia,optimism-sepolia,blast-sepolia"
else
    # Enable individual networks based on the user's input
    if [[ "$NETWORK_SELECTION" == *"ARBT"* ]]; then
        ENABLED_NETWORKS="$ENABLED_NETWORKS,arbitrum-sepolia"
    fi
    if [[ "$NETWORK_SELECTION" == *"BSSP"* ]]; then
        ENABLED_NETWORKS="$ENABLED_NETWORKS,base-sepolia"
    fi
    if [[ "$NETWORK_SELECTION" == *"OPSP"* ]]; then
        ENABLED_NETWORKS="$ENABLED_NETWORKS,optimism-sepolia"
    fi
    if [[ "$NETWORK_SELECTION" == *"BLSS"* ]]; then
        ENABLED_NETWORKS="$ENABLED_NETWORKS,blast-sepolia"
    fi
fi

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
read -p "$MSG_RPC_ENDPOINTS: " CUSTOM_RPC
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
	
	#Add new flags for better bid processing
	export EXECUTOR_PROCESS_BIDS_ENABLED=true
	export EXECUTOR_ENABLE_BIDDING_PROCESSING=true
	export EXECUTOR_PROCESS_ORDERS_API_ENABLED=true
	export EXECUTOR_RESEND_FAILED_CLAIMS=true
fi

# ASK FOR WALLET PRIVATE KEY
export PRIVATE_KEY_LOCAL=$WALLET_PRIVATE_KEY
export ENABLED_NETWORKS=$ENABLED_NETWORKS

# Export RPC endpoints
export RPC_ENDPOINTS_ARBT
export RPC_ENDPOINTS_BSSP
export RPC_ENDPOINTS_BLSS
export RPC_ENDPOINTS_OPSP
export RPC_ENDPOINTS_L1RN
export EXECUTOR_MAX_L3_GAS_PRICE=$GAS_VALUE

# Display the collected inputs and settings (for verification)
echo -e "\nCollected inputs and settings:"
echo "Node Type: $NODE_TYPE"
if [[ "$NODE_TYPE" == "rpc" ]]; then
    # Mask the API key for display
    MASKED_API_KEY="${ALCHEMY_API_KEY:0:6}******${ALCHEMY_API_KEY: -6}"
    echo "Alchemy API Key: $MASKED_API_KEY"
fi

# Mask the private key for display
MASKED_PRIVATE_KEY="${WALLET_PRIVATE_KEY:0:6}******${WALLET_PRIVATE_KEY: -6}"
echo "Wallet Private Key: $MASKED_PRIVATE_KEY"

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
echo "Enabled Networks: $ENABLED_NETWORKS"

# Step 5: Proceed with the installation or other setup steps
echo -e "\n$MSG_THANKS"
sleep 5

if $DRY_RUN; then
    echo -e "${GREEN}[Dry-run] Would run the node.${NC}"
else
    echo -e "${BLUE}Running the node...${NC}"
    ./executor
fi
