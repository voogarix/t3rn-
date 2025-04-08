#!/bin/bash
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[38;5;214m'
NC='\033[0m' # No Color

echo ">>============================================================<<";
echo "||V)    vv                                         ## X)    xx||";
echo "||V)    vv                                             X)  xx ||";
echo "||V)    vv  o)OOO   o)OOO   g)GGG  a)AAAA   r)RRR  i)   X)xx  ||";
echo "|| V)  vv  o)   OO o)   OO g)   GG  a)AAA  r)   RR i)   X)xx  ||";
echo "||  V)vv   o)   OO o)   OO g)   GG a)   A  r)      i)  X)  xx ||";
echo "||   V)     o)OOO   o)OOO   g)GGGG  a)AAAA r)      i) X)    xx||";
echo "||                              GG                            ||";
echo "||                         g)GGGG                             ||";
echo ">>============================================================<<";

echo -e "${ORANGE}-----------------------------------------------------${NC}"
echo -e "${GREEN}Get free 20€ credit for VPS on Hetzner:${NC} ${ORANGE}https://hetzner.cloud/?ref=mjjaxNOJxUW1${NC}"
echo -e "${GREEN}Get free Alchemy API:${NC} ${ORANGE}https://alchemy.com/?r=Dc3MDc2NzI5MjYwN${NC}"
sleep 3

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

# Function to check and kill running executor process
kill_running_executor() {
    local pid
    pid=$(pgrep -f "./executor")

    if [ -n "$pid" ]; then
        if $DRY_RUN; then
            echo -e "${GREEN}[Dry-run] Would kill running executor process (PID: $pid)${NC}"
        else
            echo -e "${ORANGE}$MSG_KILLING_EXECUTOR${NC}"
            kill "$pid"
            sleep 2
            echo -e "${GREEN}$MSG_EXECUTOR_KILLED${NC}"
        fi
    else
        echo -e "${BLUE}$MSG_NO_EXECUTOR_RUNNING${NC}"
    fi
}

# Function to install jq if not present
install_jq_if_needed() {
    if ! command -v jq &>/dev/null; then
        echo -e "${ORANGE}$MSG_JQ_REQUIRED${NC}"
        
        # Detect OS and install jq
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get update && sudo apt-get install -y jq
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install jq  # macOS
        elif [[ "$OSTYPE" == "alpine"* ]]; then
            apk add jq      # Alpine Linux
        else
            echo -e "${RED}$MSG_JQ_INSTALL_FAILED${NC}"
            echo "Install jq manually: https://stedolan.github.io/jq/download/"
            exit 1
        fi

        # Verify installation
        if command -v jq &>/dev/null; then
            echo -e "${GREEN}$MSG_JQ_INSTALL_SUCCESS${NC}"
        else
            echo -e "${RED}$MSG_JQ_INSTALL_FAILED${NC}"
            exit 1
        fi
    fi
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

# Install jq 
install_jq_if_needed

# Enable verbose mode if requested
if $VERBOSE; then
    set -x
fi

# Dry-run mode message
if $DRY_RUN; then
    echo -e "${ORANGE}Dry-run mode enabled. No changes will be made.${NC}"
	sleep 1
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
        echo -e "${RED}$MSG_GAS_VALUE${NC}"
        return 1
    fi

    # Check if the gas value is within the allowed range
    if (( gas_value < 100 || gas_value > 20000 )); then
        echo -e "${RED}$MSG_INVALID_GAS${NC}"
        return 1
    fi

    return 0
}  # <-- ADD THIS CLOSING BRACE

parse_rpc_input() {
    local input="$1"
    local -a endpoints
    IFS=',' read -ra endpoints <<< "$input"
    printf '['
    for ((i=0; i<${#endpoints[@]}; i++)); do
        endpoint=$(echo "${endpoints[$i]}" | xargs)  # Trim whitespace
        printf '"%s"' "$endpoint"
        [[ $i -ne $((${#endpoints[@]}-1)) ]] && printf ','
    done
    printf ']'
}

# Language selection
while true; do
    # Define MSG_INVALID_LANG for all cases
    MSG_INVALID_LANG="Invalid language code. Please try again."
	MSG_JQ_REQUIRED="jq is required..."

    echo -e "${GREEN}Select your language / Dil seçin / Выберите язык / Wählen Sie Ihre Sprache / Pilih bahasa Anda / Choisissez votre langue:${NC}"
    echo -e "${ORANGE}English (en)${NC}"
    echo -e "${ORANGE}Azerbaijani (az)${NC}"
    echo -e "${ORANGE}Russian (ru)${NC}"
    echo -e "${ORANGE}German (de)${NC}"
    echo -e "${ORANGE}Indonesian (id)${NC}"
    echo -e "${ORANGE}French (fr)${NC}"
    read -p "Enter language code (e.g., en, az, ru, de, id, fr): " LANG_CODE
	
	# Language-specific strings
    case "$LANG_CODE" in
        en)
            MSG_VERSION_CHOICE="Select version to install:"
            MSG_LATEST_OPTION="1) Latest version"
            MSG_SPECIFIC_OPTION="2) Specific version"
            MSG_ENTER_VERSION="Enter the version number you want to install (e.g., v0.51.0):"
            MSG_INVALID_VERSION_CHOICE="Invalid choice. Please enter 1 or 2"
            MSG_CLEANUP="Cleaning up previous installations..."
            MSG_DOWNLOAD="Downloading the latest release..."
            MSG_EXTRACT="Extracting the archive..."
            MSG_INVALID_INPUT="Invalid input. Please enter 'api' or 'rpc'."
            MSG_PRIVATE_KEY="Enter your wallet private key"
            MSG_GAS_VALUE="Enter the gas value (must be an integer between 100 and 20000)"
            MSG_INVALID_GAS="Error: Gas value must be between 100 and 20000."
            MSG_NODE_TYPE="Do you want to run an API node or RPC node? (api/rpc)"
            MSG_RPC_ENDPOINTS="Do you want to add custom public RPC endpoints? (y/n)"
            MSG_THANKS="If this script helped you, don't forget to give a ⭐ on GitHub 😉..."
            MSG_L1RN_RPC="Available L1RN RPC endpoints:"
            MSG_SELECT_L1RN="Enter the numbers of the L1RN RPC endpoints to enable (comma-separated, e.g., 1,2):"
            MSG_INVALID_SELECTION="Invalid selection: %s. Skipping."
            MSG_OUT_OF_RANGE="Index %s is out of range. Skipping."
            MSG_NO_SELECTION="No valid selections. Please select at least one endpoint."
            MSG_ALCHEMY_API_KEY="Enter your Alchemy API key:"
            MSG_CREATE_DIR="Creating and navigating to t3rn directory..."
            MSG_DOWNLOAD_COMPLETE="Download complete."
            MSG_NAVIGATE_BINARY="Navigating to the executor binary location..."
            MSG_COLLECTED_INPUTS="Collected inputs and settings:"
            MSG_NODE_TYPE_LABEL="Node Type:"
            MSG_ALCHEMY_API_KEY_LABEL="Alchemy API Key:"
            MSG_GAS_VALUE_LABEL="Gas Value:"
            MSG_RPC_ENDPOINTS_LABEL="Enabled Networks and RPC points:"
            MSG_WALLET_PRIVATE_KEY_LABEL="Wallet Private Key:"
            MSG_FAILED_CREATE_DIR="Failed to create or navigate to t3rn directory. Exiting."
            MSG_FAILED_FETCH_TAG="Failed to fetch the latest release tag. Please check your internet connection and try again."
            MSG_FAILED_DOWNLOAD="Failed to download the latest release. Please check the URL and try again."
            MSG_FAILED_EXTRACT="Failed to extract the archive. Please check the file and try again."
            MSG_FAILED_NAVIGATE="Failed to navigate to executor binary location. Exiting."
            MSG_DELETE_T3RN_DIR="Deleting existing t3rn directory..."
            MSG_DELETE_EXECUTOR_DIR="Deleting existing executor directory..."
            MSG_DELETE_TAR_GZ="Deleting previously downloaded tar.gz files..."
            MSG_EXTRACTION_COMPLETE="Extraction complete."
            MSG_RUNNING_NODE="Running the node..."
            MSG_DRY_RUN_DELETE="[Dry-run] Would delete existing t3rn and executor directories."
            MSG_DRY_RUN_CREATE_DIR="[Dry-run] Would create and navigate to t3rn directory."
            MSG_DRY_RUN_NAVIGATE="[Dry-run] Would navigate to executor binary location."
            MSG_DRY_RUN_RUN_NODE="[Dry-run] Would run the node."
            MSG_ENTER_CUSTOM_RPC="Enter custom RPC endpoints:"
            MSG_ARBT_RPC="Arbitrum Sepolia RPC endpoints (default: $DEFAULT_RPC_ENDPOINTS_ARBT)"
            MSG_BSSP_RPC="Base Sepolia RPC endpoints (default: $DEFAULT_RPC_ENDPOINTS_BSSP)"
            MSG_BLSS_RPC="Blast Sepolia RPC endpoints (default: $DEFAULT_RPC_ENDPOINTS_BLSS)"
            MSG_OPSP_RPC="Optimism Sepolia RPC endpoints (default: $DEFAULT_RPC_ENDPOINTS_OPSP)"
			MSG_AVAILABLE_NETWORKS="Available networks:"
			MSG_ARBT_DESC="ARBT = arbitrum-sepolia"
			MSG_BSSP_DESC="BSSP = base-sepolia"
			MSG_OPSP_DESC="OPSP = optimism-sepolia"
			MSG_BLSS_DESC="BLSS = blast-sepolia"
			MSG_L2RN_ALWAYS_ENABLED="L2RN is always enabled."
			MSG_ENTER_NETWORKS="Enter the networks you want to enable (comma-separated, e.g., ARBT,BSSP,OPSP,BLSS or press Enter/type 'all' to enable all):"
			MSG_INVALID_NETWORK="Invalid network: %s. Please enter valid networks."
			MSG_KILLING_EXECUTOR="A running executor process was found. Killing it..."
            MSG_EXECUTOR_KILLED="Executor process has been successfully terminated."
            MSG_NO_EXECUTOR_RUNNING="No running executor process found."
			MSG_CHECKING_EXECUTOR="=== Checking for running executor process ==="
            MSG_KILLING_EXECUTOR="Found running executor process. Terminating it to avoid conflicts..."
            MSG_EXECUTOR_KILLED="Old executor process successfully terminated."
            MSG_NO_EXECUTOR_RUNNING="No existing executor process found - good to proceed."
			MSG_WARNING="⚠️ WARNING: WHEN SHARING SCREENSHOTS OF THIS SCRIPT DUE TO AN ERROR, MAKE SURE YOUR PRIVATE KEYS AND ALCHEMY API KEY ARE NOT VISIBLE! OTHERWISE, YOU COULD LOSE ALL ASSETS IN YOUR WALLET OR EXPOSE YOUR API ACCESS! ⚠️"
			MSG_JQ_REQUIRED="jq is required for JSON processing. Installing jq..."
            MSG_JQ_INSTALL_FAILED="Failed to install jq. Please install it manually and try again."
            MSG_JQ_INSTALL_SUCCESS="jq installed successfully."
			MSG_NODE_TYPE_OPTIONS="Select node type:"
			MSG_API_MODE="1) API Node - Submit transactions directly via API"
			MSG_ALCHEMY_MODE="2) Alchemy RPC - Use Alchemy-managed RPC endpoints (requires API key)"
			MSG_CUSTOM_MODE="3) Custom RPC - Use public/custom RPC endpoints (no Alchemy needed)"
			MSG_API_MODE_DESC="API Mode: Direct transaction submission enabled"
			MSG_ALCHEMY_MODE_DESC="Alchemy Mode: Using Alchemy endpoints for RPC"
			MSG_CUSTOM_MODE_DESC="Custom RPC Mode: Using public/custom endpoints"
			MSG_SELECT_NODE_TYPE="Enter your choice (1/2/3): "
			MSG_INVALID_NODE_TYPE="Invalid node type selection. Please enter 1, 2, or 3."
            break
            ;;
        az)
            MSG_INVALID_LANG="Yanlış dil kodu. Yenidən cəhd edin."
			MSG_VERSION_CHOICE="Yükləmək üçün versiyanı seçin:"
			MSG_LATEST_OPTION="1) Son versiya"
			MSG_SPECIFIC_OPTION="2) Xüsusi versiya" 
			MSG_ENTER_VERSION="Yükləmək istədiyiniz versiya nömrəsini daxil edin (məsələn, v0.51.0):"
			MSG_INVALID_VERSION_CHOICE="Yanlış seçim. Zəhmət olmasa 1 və ya 2 daxil edin"
			MSG_INVALID_VERSION_FORMAT="Yanlış versiya formatı. v0.51.0 kimi olmalıdır"
            MSG_CLEANUP="Əvvəlki quraşdırmaları təmizləyirəm..."
            MSG_DOWNLOAD="Son buraxılışı yükləyirəm..."
            MSG_EXTRACT="Arxiv açılır..."
            MSG_INVALID_INPUT="Yanlış giriş. 'api' və ya 'rpc' daxil edin."
            MSG_PRIVATE_KEY="Cüzdanınızın gizli açarını daxil edin"
            MSG_GAS_VALUE="Qaz dəyərini daxil edin (100 ilə 20000 arasında tam ədəd olmalıdır)"
            MSG_INVALID_GAS="Xəta: Qaz dəyəri 100 ilə 20000 arasında olmalıdır."
            MSG_NODE_TYPE="API node və ya RPC node işlətmək istəyirsiniz? (api/rpc)"
            MSG_RPC_ENDPOINTS="Xüsusi RPC endpointləri əlavə etmək istəyirsiniz? (y/n)"
            MSG_THANKS="Bu skript sizə kömək etdisə, GitHub-da ⭐ verməyi unutmayın 😉..."
            MSG_L1RN_RPC="Mövcud L1RN RPC endpointləri:"
            MSG_SELECT_L1RN="Aktivləşdirmək istədiyiniz L1RN RPC endpointlərinin nömrələrini daxil edin (vergüllə ayrılmış, məsələn, 1,2):"
            MSG_INVALID_SELECTION="Yanlış seçim: %s. Keçilir."
            MSG_OUT_OF_RANGE="İndeks %s aralıqdan kənardır. Keçilir."
            MSG_NO_SELECTION="Heç bir etibarlı seçim yoxdur. Ən azı bir endpoint seçin."
            MSG_ALCHEMY_API_KEY="Alchemy API açarınızı daxil edin:"
            MSG_CREATE_DIR="t3rn qovluğu yaradılır və ora keçid edilir..."
            MSG_DOWNLOAD_COMPLETE="Yükləmə tamamlandı."
            MSG_NAVIGATE_BINARY="Executor binar faylı yerləşən qovluğa keçid edilir..."
            MSG_COLLECTED_INPUTS="Toplanmış məlumatlar və parametrlər:"
            MSG_NODE_TYPE_LABEL="Node Növü:"
            MSG_ALCHEMY_API_KEY_LABEL="Alchemy API Açarı:"
            MSG_GAS_VALUE_LABEL="Qaz Dəyəri:"
            MSG_RPC_ENDPOINTS_LABEL="Aktiv Şəbəkələr və RPC Nöqtələri:"
            MSG_WALLET_PRIVATE_KEY_LABEL="Cüzdanın Gizli Açarı:"
            MSG_FAILED_CREATE_DIR="t3rn qovluğu yaradıla bilmədi və ya ora keçid edilə bilmədi. Çıxılır."
            MSG_FAILED_FETCH_TAG="Son buraxılış etiketi alına bilmədi. İnternet bağlantınızı yoxlayın və yenidən cəhd edin."
            MSG_FAILED_DOWNLOAD="Son buraxılış yüklənə bilmədi. URL-i yoxlayın və yenidən cəhd edin."
            MSG_FAILED_EXTRACT="Arxiv açıla bilmədi. Faylı yoxlayın və yenidən cəhd edin."
            MSG_FAILED_NAVIGATE="Executor binar faylı yerləşən qovluğa keçid edilə bilmədi. Çıxılır."
            MSG_DELETE_T3RN_DIR="Mövcud t3rn qovluğu silinir..."
            MSG_DELETE_EXECUTOR_DIR="Mövcud executor qovluğu silinir..."
            MSG_DELETE_TAR_GZ="Əvvəlcədən yüklənmiş tar.gz faylları silinir..."
            MSG_EXTRACTION_COMPLETE="Arxiv açıldı."
            MSG_RUNNING_NODE="Node işə salınır..."
            MSG_DRY_RUN_DELETE="[Dry-run] Mövcud t3rn və executor qovluqları silinəcək."
            MSG_DRY_RUN_CREATE_DIR="[Dry-run] t3rn qovluğu yaradılacaq və ora keçid ediləcək."
            MSG_DRY_RUN_NAVIGATE="[Dry-run] Executor binar faylı yerləşən qovluğa keçid ediləcək."
            MSG_DRY_RUN_RUN_NODE="[Dry-run] Node işə salınacaq."
            MSG_ENTER_CUSTOM_RPC="Xüsusi RPC endpointlərini daxil edin:"
            MSG_ARBT_RPC="Arbitrum Sepolia RPC endpointləri (default: $DEFAULT_RPC_ENDPOINTS_ARBT)"
            MSG_BSSP_RPC="Base Sepolia RPC endpointləri (default: $DEFAULT_RPC_ENDPOINTS_BSSP)"
            MSG_BLSS_RPC="Blast Sepolia RPC endpointləri (default: $DEFAULT_RPC_ENDPOINTS_BLSS)"
            MSG_OPSP_RPC="Optimism Sepolia RPC endpointləri (default: $DEFAULT_RPC_ENDPOINTS_OPSP)"
			MSG_AVAILABLE_NETWORKS="Mövcud şəbəkələr:"
            MSG_ARBT_DESC="ARBT = arbitrum-sepolia"
            MSG_BSSP_DESC="BSSP = base-sepolia"
            MSG_OPSP_DESC="OPSP = optimism-sepolia" 
            MSG_BLSS_DESC="BLSS = blast-sepolia"
            MSG_L2RN_ALWAYS_ENABLED="L2RN həmişə aktivdir."
            MSG_ENTER_NETWORKS="Aktiv etmək istədiyiniz şəbəkələri daxil edin (vergüllə ayrılmış, məsələn, ARBT,BSSP,OPSP,BLSS və ya hamısını aktiv etmək üçün Enter düyməsini basın/'all' yazın):"
            MSG_INVALID_NETWORK="Yanlış şəbəkə: %s. Zəhmət olmasa etibarlı şəbəkələri daxil edin."
			MSG_KILLING_EXECUTOR="İşləyən executor prosesi tapıldı. Proses sonlandırılır..."
            MSG_EXECUTOR_KILLED="Executor prosesi uğurla sonlandırıldı."
            MSG_NO_EXECUTOR_RUNNING="İşləyən executor prosesi tapılmadı."
			MSG_CHECKING_EXECUTOR="=== İşlək executor prosesinin yoxlanılması ==="
            MSG_KILLING_EXECUTOR="İşlək executor prosesi aşkarlandı. Ziddiyyətlərin qarşısını almaq üçün dayandırılır..."
            MSG_EXECUTOR_KILLED="Köhnə executor prosesi uğurla dayandırıldı."
            MSG_NO_EXECUTOR_RUNNING="İşlək executor prosesi tapılmadı - davam etmək təhlükəsizdir."
			MSG_WARNING="⚠️ XƏBƏRDARLIQ: HƏR HANSI BİR XƏTAYA GÖRƏ BU SKRİPTİN EKRAN ŞƏKİLLƏRİNİ PAYLAŞARKƏN, ŞƏXSİ AÇARLARINIZIN VƏ ALCHEMY API AÇARINIZIN GÖRÜNMƏDİYİNDƏN ƏMIN OLUN! ƏKS HALDA, CÜZDANINIZDAKI BÜTÜN AKTİVLƏRİ İTİRƏ VƏ YA API MƏLUMATLARINIZI İFŞA EDƏ BİLƏRSİNİZ! ⚠️"
			MSG_JQ_REQUIRED="JSON emalı üçün jq tələb olunur. jq quraşdırılır..."
            MSG_JQ_INSTALL_FAILED="jq quraşdırıla bilmədi. Zəhmət olmasa əl ilə quraşdırın və yenidən cəhd edin."
            MSG_JQ_INSTALL_SUCCESS="jq uğurla quraşdırıldı."
			MSG_NODE_TYPE_OPTIONS="Node növünü seçin:"
			MSG_API_MODE="1) API Node - Tranzaksiyaları birbaşa API vasitəsilə göndərir"
			MSG_ALCHEMY_MODE="2) Alchemy RPC - Alchemy tərəfindən idarə olunan RPC endpointləri (API açarı tələb olunur)"
			MSG_CUSTOM_MODE="3) Xüsusi RPC - İctimai/xüsusi RPC endpointləri istifadə edir (Alchemy tələb olunmur)"
			MSG_API_MODE_DESC="API Rejimi: Birbaşa tranzaksiya göndərmə aktivdir"
			MSG_ALCHEMY_MODE_DESC="Alchemy Rejimi: RPC üçün Alchemy endpointləri istifadə olunur"
			MSG_CUSTOM_MODE_DESC="Xüsusi RPC Rejimi: İctimai/xüsusi endpointlər istifadə olunur"
			MSG_SELECT_NODE_TYPE="Seçiminizi daxil edin (1/2/3): "
			MSG_INVALID_NODE_TYPE="Yanlış node növü seçimi. Zəhmət olmasa 1, 2 və ya 3 daxil edin."
            break
            ;;
        ru)
            MSG_INVALID_LANG="Неверный код языка. Пожалуйста, попробуйте снова."
			MSG_VERSION_CHOICE="Выберите версию для установки:"
			MSG_LATEST_OPTION="1) Последняя версия"
			MSG_SPECIFIC_OPTION="2) Конкретная версия"
			MSG_ENTER_VERSION="Введите номер версии, которую вы хотите установить (например, v0.51.0):"
			MSG_INVALID_VERSION_CHOICE="Неверный выбор. Пожалуйста, введите 1 или 2"
			MSG_INVALID_VERSION_FORMAT="Неверный формат версии. Должно быть как v0.51.0"
            MSG_CLEANUP="Очистка предыдущих установок..."
            MSG_DOWNLOAD="Загрузка последнего релиза..."
            MSG_EXTRACT="Распаковка архива..."
            MSG_INVALID_INPUT="Неверный ввод. Пожалуйста, введите 'api' или 'rpc'."
            MSG_PRIVATE_KEY="Введите ваш приватный ключ кошелька"
            MSG_GAS_VALUE="Введите значение газа (должно быть целым числом от 100 до 20000)"
            MSG_INVALID_GAS="Ошибка: Значение газа должно быть от 100 до 20000."
            MSG_NODE_TYPE="Вы хотите запустить API-узел или RPC-узел? (api/rpc)"
            MSG_RPC_ENDPOINTS="Хотите добавить пользовательские RPC-точки? (y/n)"
            MSG_THANKS="Если этот скрипт помог вам, не забудьте поставить ⭐ на GitHub 😉..."
            MSG_L1RN_RPC="Доступные L1RN RPC endpoints:"
            MSG_SELECT_L1RN="Введите номера L1RN RPC endpoints для включения (через запятую, например, 1,2):"
            MSG_INVALID_SELECTION="Неверный выбор: %s. Пропускаем."
            MSG_OUT_OF_RANGE="Индекс %s вне диапазона. Пропускаем."
            MSG_NO_SELECTION="Нет допустимых выборов. Пожалуйста, выберите хотя бы один endpoint."
            MSG_ALCHEMY_API_KEY="Введите ваш Alchemy API ключ:"
            MSG_CREATE_DIR="Создание и переход в директорию t3rn..."
            MSG_DOWNLOAD_COMPLETE="Загрузка завершена."
            MSG_NAVIGATE_BINARY="Переход к расположению бинарного файла executor..."
            MSG_COLLECTED_INPUTS="Собранные данные и настройки:"
            MSG_NODE_TYPE_LABEL="Тип узла:"
            MSG_ALCHEMY_API_KEY_LABEL="Ключ Alchemy API:"
            MSG_GAS_VALUE_LABEL="Значение газа:"
            MSG_RPC_ENDPOINTS_LABEL="Активные сети и RPC-точки:"
            MSG_WALLET_PRIVATE_KEY_LABEL="Приватный ключ кошелька:"
            MSG_FAILED_CREATE_DIR="Не удалось создать или перейти в директорию t3rn. Выход."
            MSG_FAILED_FETCH_TAG="Не удалось получить последний тег релиза. Проверьте подключение к интернету и попробуйте снова."
            MSG_FAILED_DOWNLOAD="Не удалось загрузить последний релиз. Проверьте URL и попробуйте снова."
            MSG_FAILED_EXTRACT="Не удалось извлечь архив. Проверьте файл и попробуйте снова."
            MSG_FAILED_NAVIGATE="Не удалось перейти к расположению бинарного файла executor. Выход."
            MSG_DELETE_T3RN_DIR="Удаление существующей директории t3rn..."
            MSG_DELETE_EXECUTOR_DIR="Удаление существующей директории executor..."
            MSG_DELETE_TAR_GZ="Удаление ранее загруженных tar.gz файлов..."
            MSG_EXTRACTION_COMPLETE="Архив успешно извлечен."
            MSG_RUNNING_NODE="Запуск узла..."
            MSG_DRY_RUN_DELETE="[Dry-run] Существующие директории t3rn и executor будут удалены."
            MSG_DRY_RUN_CREATE_DIR="[Dry-run] Будет создана и открыта директория t3rn."
            MSG_DRY_RUN_NAVIGATE="[Dry-run] Будет выполнен переход к расположению бинарного файла executor."
            MSG_DRY_RUN_RUN_NODE="[Dry-run] Узел будет запущен."
            MSG_ENTER_CUSTOM_RPC="Введите пользовательские RPC-точки:"
            MSG_ARBT_RPC="Arbitrum Sepolia RPC-точки (по умолчанию: $DEFAULT_RPC_ENDPOINTS_ARBT)"
            MSG_BSSP_RPC="Base Sepolia RPC-точки (по умолчанию: $DEFAULT_RPC_ENDPOINTS_BSSP)"
            MSG_BLSS_RPC="Blast Sepolia RPC-точки (по умолчанию: $DEFAULT_RPC_ENDPOINTS_BLSS)"
            MSG_OPSP_RPC="Optimism Sepolia RPC-точки (по умолчанию: $DEFAULT_RPC_ENDPOINTS_OPSP)"
			MSG_AVAILABLE_NETWORKS="Доступные сети:"
            MSG_ARBT_DESC="ARBT = arbitrum-sepolia"
            MSG_BSSP_DESC="BSSP = base-sepolia"
            MSG_OPSP_DESC="OPSP = optimism-sepolia"
            MSG_BLSS_DESC="BLSS = blast-sepolia"
            MSG_L2RN_ALWAYS_ENABLED="L2RN всегда включен."
            MSG_ENTER_NETWORKS="Введите сети, которые хотите активировать (через запятую, например: ARBT,BSSP,OPSP,BLSS или нажмите Enter/введите 'all' для всех):"
            MSG_INVALID_NETWORK="Неверная сеть: %s. Пожалуйста, введите корректные сети."
			MSG_KILLING_EXECUTOR="Найден запущенный процесс executor. Завершение процесса..."
            MSG_EXECUTOR_KILLED="Процесс executor успешно завершен."
            MSG_NO_EXECUTOR_RUNNING="Запущенных процессов executor не найдено."
			MSG_CHECKING_EXECUTOR="=== Проверка запущенных процессов executor ==="
            MSG_KILLING_EXECUTOR="Обнаружен запущенный процесс executor. Останавливаем для предотвращения конфликтов..."
            MSG_EXECUTOR_KILLED="Старый процесс executor успешно остановлен."
            MSG_NO_EXECUTOR_RUNNING="Запущенных процессов executor не обнаружено - можно продолжать."
			MSG_WARNING="⚠️ ПРЕДУПРЕЖДЕНИЕ: ЕСЛИ ВЫ ДЕЛИТЕСЬ СКРИНШОТАМИ ЭТОГО СКРИПТА ИЗ-ЗА ОШИБКИ, УБЕДИТЕСЬ, ЧТО ВАШИ ПРИВАТНЫЕ КЛЮЧИ И КЛЮЧ ALCHEMY API НЕ ВИДНЫ! В ПРОТИВНОМ СЛУЧАЕ ВЫ МОЖЕТЕ ПОТЕРЯТЬ ВСЕ СВОИ АКТИВЫ В КОШЕЛЬКЕ ИЛИ РАСКРЫТЬ ДОСТУП К API! ⚠️"
			MSG_JQ_REQUIRED="jq требуется для обработки JSON. Установка jq..."
            MSG_JQ_INSTALL_FAILED="Не удалось установить jq. Пожалуйста, установите его вручную и попробуйте снова."
            MSG_JQ_INSTALL_SUCCESS="jq успешно установлен."
			MSG_NODE_TYPE_OPTIONS="Выберите тип узла:"
			MSG_API_MODE="1\) API Узел - Прямая отправка транзакций через API"
			MSG_ALCHEMY_MODE="2) Alchemy RPC - Использование RPC endpoints от Alchemy (требуется API-ключ)"
			MSG_CUSTOM_MODE="3) Кастомный RPC - Использование публичных/пользовательских RPC endpoints (Alchemy не требуется)"
			MSG_API_MODE_DESC="Режим API: Прямая отправка транзакций включена"
			MSG_ALCHEMY_MODE_DESC="Режим Alchemy: Используются RPC endpoints от Alchemy"
			MSG_CUSTOM_MODE_DESC="Режим кастомного RPC: Используются публичные/пользовательские endpoints"
			MSG_SELECT_NODE_TYPE="Введите ваш выбор (1/2/3): "
			MSG_INVALID_NODE_TYPE="Неверный выбор типа узла. Пожалуйста, введите 1, 2 или 3."
            break
            ;;
        de)
            MSG_INVALID_LANG="Ungültiger Sprachcode. Bitte versuchen Sie es erneut."
            MSG_CLEANUP="Vorherige Installationen werden bereinigt..."
            MSG_DOWNLOAD="Die neueste Version wird heruntergeladen..."
            MSG_EXTRACT="Das Archiv wird entpackt..."
            MSG_INVALID_INPUT="Ungültige Eingabe. Bitte geben Sie 'api' oder 'rpc' ein."
            MSG_PRIVATE_KEY="Geben Sie Ihren privaten Wallet-Schlüssel ein"
            MSG_GAS_VALUE="Geben Sie den Gas-Wert ein (muss eine ganze Zahl zwischen 100 und 20000 sein)"
            MSG_INVALID_GAS="Fehler: Der Gas-Wert muss zwischen 100 und 20000 liegen."
            MSG_NODE_TYPE="Möchten Sie einen API-Knoten oder RPC-Knoten ausführen? (api/rpc)"
            MSG_RPC_ENDPOINTS="Möchten Sie benutzerdefinierte RPC-Endpoints hinzufügen? (y/n)"
            MSG_THANKS="Wenn Ihnen dieses Skript geholfen hat, vergessen Sie nicht, auf GitHub einen ⭐ zu hinterlassen 😉..."
            MSG_L1RN_RPC="Verfügbare L1RN RPC-Endpunkte:"
            MSG_SELECT_L1RN="Geben Sie die Nummern der zu aktivierenden L1RN RPC-Endpunkte ein (durch Kommas getrennt, z.B. 1,2):"
            MSG_INVALID_SELECTION="Ungültige Auswahl: %s. Übersprungen."
            MSG_OUT_OF_RANGE="Index %s liegt außerhalb des gültigen Bereichs. Übersprungen."
            MSG_NO_SELECTION="Keine gültigen Auswahlen. Bitte wählen Sie mindestens einen Endpunkt aus."
            MSG_ALCHEMY_API_KEY="Geben Sie Ihren Alchemy API-Schlüssel ein:"
            MSG_CREATE_DIR="Erstellen und Navigieren zum t3rn-Verzeichnis..."
            MSG_DOWNLOAD_COMPLETE="Download abgeschlossen."
            MSG_NAVIGATE_BINARY="Navigieren zum Speicherort der Executor-Binärdatei..."
            MSG_COLLECTED_INPUTS="Gesammelte Eingaben und Einstellungen:"
            MSG_NODE_TYPE_LABEL="Knotentyp:"
            MSG_ALCHEMY_API_KEY_LABEL="Alchemy API-Schlüssel:"
            MSG_GAS_VALUE_LABEL="Gaswert:"
            MSG_RPC_ENDPOINTS_LABEL="Aktivierte Netzwerke und RPC-Punkte:"
            MSG_WALLET_PRIVATE_KEY_LABEL="Wallet-Privatschlüssel:"
            MSG_FAILED_CREATE_DIR="Fehler beim Erstellen oder Navigieren zum t3rn-Verzeichnis. Beenden."
            MSG_FAILED_FETCH_TAG="Fehler beim Abrufen des neuesten Release-Tags. Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut."
            MSG_FAILED_DOWNLOAD="Fehler beim Herunterladen des neuesten Releases. Bitte überprüfen Sie die URL und versuchen Sie es erneut."
            MSG_FAILED_EXTRACT="Fehler beim Entpacken des Archivs. Bitte überprüfen Sie die Datei und versuchen Sie es erneut."
            MSG_FAILED_NAVIGATE="Fehler beim Navigieren zum Speicherort der Executor-Binärdatei. Beenden."
            MSG_DELETE_T3RN_DIR="Löschen des vorhandenen t3rn-Verzeichnisses..."
            MSG_DELETE_EXECUTOR_DIR="Löschen des vorhandenen executor-Verzeichnisses..."
            MSG_DELETE_TAR_GZ="Löschen der zuvor heruntergeladenen tar.gz-Dateien..."
            MSG_EXTRACTION_COMPLETE="Entpacken abgeschlossen."
            MSG_RUNNING_NODE="Node wird gestartet..."
            MSG_DRY_RUN_DELETE="[Dry-run] Vorhandene t3rn- und executor-Verzeichnisse würden gelöscht."
            MSG_DRY_RUN_CREATE_DIR="[Dry-run] t3rn-Verzeichnis würde erstellt und dorthin navigiert."
            MSG_DRY_RUN_NAVIGATE="[Dry-run] Würde zum Speicherort der Executor-Binärdatei navigieren."
            MSG_DRY_RUN_RUN_NODE="[Dry-run] Node würde gestartet."
            MSG_ENTER_CUSTOM_RPC="Geben Sie benutzerdefinierte RPC-Endpunkte ein:"
            MSG_ARBT_RPC="Arbitrum Sepolia RPC-Endpunkte (Standard: $DEFAULT_RPC_ENDPOINTS_ARBT)"
            MSG_BSSP_RPC="Base Sepolia RPC-Endpunkte (Standard: $DEFAULT_RPC_ENDPOINTS_BSSP)"
            MSG_BLSS_RPC="Blast Sepolia RPC-Endpunkte (Standard: $DEFAULT_RPC_ENDPOINTS_BLSS)"
            MSG_OPSP_RPC="Optimism Sepolia RPC-Endpunkte (Standard: $DEFAULT_RPC_ENDPOINTS_OPSP)"
			MSG_AVAILABLE_NETWORKS="Verfügbare Netzwerke:"
            MSG_ARBT_DESC="ARBT = arbitrum-sepolia"
            MSG_BSSP_DESC="BSSP = base-sepolia"
            MSG_OPSP_DESC="OPSP = optimism-sepolia"
            MSG_BLSS_DESC="BLSS = blast-sepolia"
            MSG_L2RN_ALWAYS_ENABLED="L2RN ist immer aktiviert."
            MSG_ENTER_NETWORKS="Geben Sie die zu aktivierenden Netzwerke ein (kommagetrennt, z.B. ARBT,BSSP,OPSP,BLSS oder Enter/'all' für alle):"
            MSG_INVALID_NETWORK="Ungültiges Netzwerk: %s. Bitte gültige Netzwerke eingeben."
			MSG_KILLING_EXECUTOR="Ein laufender Executor-Prozess wurde gefunden. Wird beendet..."
            MSG_EXECUTOR_KILLED="Executor-Prozess wurde erfolgreich beendet."
            MSG_NO_EXECUTOR_RUNNING="Kein laufender Executor-Prozess gefunden."
			MSG_CHECKING_EXECUTOR="=== Überprüfung laufender Executor-Prozesse ==="
            MSG_KILLING_EXECUTOR="Laufender Executor-Prozess gefunden. Wird beendet um Konflikte zu vermeiden..."
            MSG_EXECUTOR_KILLED="Alter Executor-Prozess erfolgreich beendet."
            MSG_NO_EXECUTOR_RUNNING="Kein laufender Executor-Prozess gefunden - fortfahren ist sicher."
			MSG_WARNING="⚠️ WARNUNG: WENN SIE SCREENSHOTS DIESES SKRIPTS AUFGRUND EINES FEHLERS TEILEN, STELLEN SIE SICHER, DASS IHRE PRIVATEN SCHLÜSSEL UND IHR ALCHEMY-API-SCHLÜSSEL NICHT SICHTBAR SIND! ANDERNFALLS KÖNNTEN SIE ALLE IHRE VERMÖGENSWERTE IM WALLET VERLIEREN ODER IHREN API-ZUGANG OFFENLEGEN! ⚠️"
			MSG_JQ_REQUIRED="jq wird für die JSON-Verarbeitung benötigt. Installiere jq..."
            MSG_JQ_INSTALL_FAILED="Installation von jq fehlgeschlagen. Bitte installieren Sie es manuell und versuchen Sie es erneut."
            MSG_JQ_INSTALL_SUCCESS="jq erfolgreich installiert."
			MSG_NODE_TYPE_OPTIONS="Knotentyp auswählen:"
			MSG_API_MODE="1) API-Knoten - Direkte Transaktionsübermittlung via API"
			MSG_ALCHEMY_MODE="2) Alchemy RPC - Nutzt Alchemy-verwaltete RPC-Endpunkte (API-Schlüssel erforderlich)"
			MSG_CUSTOM_MODE="3) Benutzerdefinierter RPC - Nutzt öffentliche/benutzerdefinierte RPC-Endpunkte (kein Alchemy benötigt)"
			MSG_API_MODE_DESC="API-Modus: Direkte Transaktionsübermittlung aktiviert"
			MSG_ALCHEMY_MODE_DESC="Alchemy-Modus: Alchemy-Endpunkte werden verwendet"
			MSG_CUSTOM_MODE_DESC="Benutzerdefinierter RPC-Modus: Öffentliche/benutzerdefinierte Endpunkte werden verwendet"
			MSG_SELECT_NODE_TYPE="Treffen Sie Ihre Wahl (1/2/3): "
			MSG_INVALID_NODE_TYPE="Ungültige Knotentyp-Auswahl. Bitte 1, 2 oder 3 eingeben."
			MSG_VERSION_CHOICE="Zu installierende Version auswählen:"
			MSG_LATEST_OPTION="1) Neueste Version"
			MSG_SPECIFIC_OPTION="2) Spezifische Version"
			MSG_ENTER_VERSION="Geben Sie die zu installierende Versionsnummer ein (z.B. v0.51.0):"
			MSG_INVALID_VERSION_CHOICE="Ungültige Auswahl. Bitte 1 oder 2 eingeben"
			MSG_INVALID_VERSION_FORMAT="Ungültiges Versionsformat. Muss wie v0.51.0 sein"
            break
            ;;
        id)
            MSG_INVALID_LANG="Kode bahasa tidak valid. Silakan coba lagi."
			MSG_VERSION_CHOICE="Pilih versi yang akan diinstal:"
			MSG_LATEST_OPTION="1) Versi terbaru"
			MSG_SPECIFIC_OPTION="2) Versi spesifik"
			MSG_ENTER_VERSION="Masukkan nomor versi yang ingin Anda instal (contoh: v0.51.0):"
			MSG_INVALID_VERSION_CHOICE="Pilihan tidak valid. Harap masukkan 1 atau 2"
			MSG_INVALID_VERSION_FORMAT="Format versi tidak valid. Harus seperti v0.51.0"
            MSG_CLEANUP="Membersihkan instalasi sebelumnya..."
            MSG_DOWNLOAD="Mengunduh rilis terbaru..."
            MSG_EXTRACT="Mengekstrak arsip..."
            MSG_INVALID_INPUT="Input tidak valid. Masukkan 'api' atau 'rpc'."
            MSG_PRIVATE_KEY="Masukkan kunci pribadi dompet Anda"
            MSG_GAS_VALUE="Masukkan nilai gas (harus bilangan bulat antara 100 dan 20000)"
            MSG_INVALID_GAS="Kesalahan: Nilai gas harus antara 100 dan 20000."
            MSG_NODE_TYPE="Apakah Anda ingin menjalankan node API atau node RPC? (api/rpc)"
            MSG_RPC_ENDPOINTS="Apakah Anda ingin menambahkan endpoint RPC kustom? (y/n)"
            MSG_THANKS="Jika skrip ini membantu Anda, jangan lupa beri ⭐ di GitHub 😉..."
            MSG_L1RN_RPC="Endpoint L1RN RPC yang tersedia:"
            MSG_SELECT_L1RN="Masukkan nomor endpoint L1RN RPC yang ingin diaktifkan (dipisahkan koma, misalnya, 1,2):"
            MSG_INVALID_SELECTION="Pilihan tidak valid: %s. Dilewati."
            MSG_OUT_OF_RANGE="Indeks %s di luar rentang. Dilewati."
            MSG_NO_SELECTION="Tidak ada pilihan yang valid. Silakan pilih setidaknya satu endpoint."
            MSG_ALCHEMY_API_KEY="Masukkan kunci API Alchemy Anda:"
            MSG_CREATE_DIR="Membuat dan menavigasi ke direktori t3rn..."
            MSG_DOWNLOAD_COMPLETE="Unduhan selesai."
            MSG_NAVIGATE_BINARY="Menavigasi ke lokasi biner executor..."
            MSG_COLLECTED_INPUTS="Input dan pengaturan yang dikumpulkan:"
            MSG_NODE_TYPE_LABEL="Tipe Node:"
            MSG_ALCHEMY_API_KEY_LABEL="Kunci API Alchemy:"
            MSG_GAS_VALUE_LABEL="Nilai Gas:"
            MSG_RPC_ENDPOINTS_LABEL="Jaringan yang Diaktifkan dan Titik RPC:"
            MSG_WALLET_PRIVATE_KEY_LABEL="Kunci Pribadi Dompet:"
            MSG_FAILED_CREATE_DIR="Gagal membuat atau berpindah ke direktori t3rn. Keluar."
            MSG_FAILED_FETCH_TAG="Gagal mengambil tag rilis terbaru. Silakan periksa koneksi internet Anda dan coba lagi."
            MSG_FAILED_DOWNLOAD="Gagal mengunduh rilis terbaru. Silakan periksa URL dan coba lagi."
            MSG_FAILED_EXTRACT="Gagal mengekstrak arsip. Silakan periksa file dan coba lagi."
            MSG_FAILED_NAVIGATE="Gagal berpindah ke lokasi biner executor. Keluar."
            MSG_DELETE_T3RN_DIR="Menghapus direktori t3rn yang ada..."
            MSG_DELETE_EXECUTOR_DIR="Menghapus direktori executor yang ada..."
            MSG_DELETE_TAR_GZ="Menghapus file tar.gz yang sebelumnya diunduh..."
            MSG_EXTRACTION_COMPLETE="Ekstraksi selesai."
            MSG_RUNNING_NODE="Menjalankan node..."
            MSG_DRY_RUN_DELETE="[Dry-run] Direktori t3rn dan executor yang ada akan dihapus."
            MSG_DRY_RUN_CREATE_DIR="[Dry-run] Direktori t3rn akan dibuat dan akan berpindah ke sana."
            MSG_DRY_RUN_NAVIGATE="[Dry-run] Akan berpindah ke lokasi biner executor."
            MSG_DRY_RUN_RUN_NODE="[Dry-run] Node akan dijalankan."
            MSG_ENTER_CUSTOM_RPC="Masukkan endpoint RPC kustom:"
            MSG_ARBT_RPC="Arbitrum Sepolia RPC endpoint (default: $DEFAULT_RPC_ENDPOINTS_ARBT)"
            MSG_BSSP_RPC="Base Sepolia RPC endpoint (default: $DEFAULT_RPC_ENDPOINTS_BSSP)"
            MSG_BLSS_RPC="Blast Sepolia RPC endpoint (default: $DEFAULT_RPC_ENDPOINTS_BLSS)"
            MSG_OPSP_RPC="Optimism Sepolia RPC endpoint (default: $DEFAULT_RPC_ENDPOINTS_OPSP)"
			MSG_AVAILABLE_NETWORKS="Jaringan yang tersedia:"
            MSG_ARBT_DESC="ARBT = arbitrum-sepolia"
            MSG_BSSP_DESC="BSSP = base-sepolia"
            MSG_OPSP_DESC="OPSP = optimism-sepolia"
            MSG_BLSS_DESC="BLSS = blast-sepolia"
            MSG_L2RN_ALWAYS_ENABLED="L2RN selalu diaktifkan."
            MSG_ENTER_NETWORKS="Masukkan jaringan yang ingin Anda aktifkan (dipisahkan koma, contoh: ARBT,BSSP,OPSP,BLSS atau tekan Enter/ketik 'all' untuk semua):"
            MSG_INVALID_NETWORK="Jaringan tidak valid: %s. Silakan masukkan jaringan yang valid."
			MSG_KILLING_EXECUTOR="Proses executor yang sedang berjalan ditemukan. Menghentikannya..."
            MSG_EXECUTOR_KILLED="Proses executor telah berhasil dihentikan."
            MSG_NO_EXECUTOR_RUNNING="Tidak ada proses executor yang sedang berjalan."
			MSG_CHECKING_EXECUTOR="=== Memeriksa proses executor yang sedang berjalan ==="
            MSG_KILLING_EXECUTOR="Proses executor yang sedang berjalan ditemukan. Menghentikan untuk menghindari konflik..."
            MSG_EXECUTOR_KILLED="Proses executor lama berhasil dihentikan."
            MSG_NO_EXECUTOR_RUNNING="Tidak ada proses executor yang berjalan - aman untuk melanjutkan."
			MSG_WARNING="⚠️ PERINGATAN: SAAT MEMBAGIKAN SCREENSHOT DARI SCRIPT INI KARENA TERJADI KESALAHAN, PASTIKAN KUNCI PRIBADI DAN KUNCI ALCHEMY API ANDA TIDAK TERLIHAT! JIKA TIDAK, ANDA BISA KEHILANGAN SELURUH ASET DI DOMPET ANDA ATAU MENGUNGKAPKAN AKSES API ANDA! ⚠️"
			MSG_JQ_REQUIRED="jq diperlukan untuk pemrosesan JSON. Menginstal jq..."
            MSG_JQ_INSTALL_FAILED="Gagal menginstal jq. Silakan instal secara manual dan coba lagi."
            MSG_JQ_INSTALL_SUCCESS="jq berhasil diinstal."
			MSG_NODE_TYPE_OPTIONS="Pilih jenis node:"
			MSG_API_MODE="1) Node API - Mengirim transaksi langsung melalui API"
			MSG_ALCHEMY_MODE="2) RPC Alchemy - Menggunakan endpoint RPC yang dikelola Alchemy (memerlukan kunci API)"
			MSG_CUSTOM_MODE="3) RPC Kustom - Menggunakan endpoint RPC publik/kustom (tidak perlu Alchemy)"
			MSG_API_MODE_DESC="Mode API: Pengiriman transaksi langsung diaktifkan"
			MSG_ALCHEMY_MODE_DESC="Mode Alchemy: Menggunakan endpoint Alchemy untuk RPC"
			MSG_CUSTOM_MODE_DESC="Mode RPC Kustom: Menggunakan endpoint publik/kustom"
			MSG_SELECT_NODE_TYPE="Masukkan pilihan Anda (1/2/3): "
			MSG_INVALID_NODE_TYPE="Pilihan jenis node tidak valid. Harap masukkan 1, 2, atau 3."
            break
            ;;
        fr)
            MSG_INVALID_LANG="Code de langue invalide. Veuillez réessayer."
			MSG_VERSION_CHOICE="Sélectionnez la version à installer :"
			MSG_LATEST_OPTION="1) Dernière version"
			MSG_SPECIFIC_OPTION="2) Version spécifique"
			MSG_ENTER_VERSION="Entrez le numéro de version que vous souhaitez installer (ex. v0.51.0) :"
			MSG_INVALID_VERSION_CHOICE="Choix invalide. Veuillez entrer 1 ou 2"
			MSG_INVALID_VERSION_FORMAT="Format de version invalide. Doit être comme v0.51.0"
            MSG_CLEANUP="Nettoyage des installations précédentes..."
            MSG_DOWNLOAD="Téléchargement de la dernière version..."
            MSG_EXTRACT="Extraction de l'archive..."
            MSG_INVALID_INPUT="Entrée invalide. Veuillez entrer 'api' ou 'rpc'."
            MSG_PRIVATE_KEY="Entrez votre clé privée de portefeuille"
            MSG_GAS_VALUE="Entrez la valeur du gaz (doit être un entier entre 100 et 20000)"
            MSG_INVALID_GAS="Erreur : La valeur du gaz doit être comprise entre 100 et 20000."
            MSG_NODE_TYPE="Voulez-vous exécuter un nœud API ou un nœud RPC ? (api/rpc)"
            MSG_RPC_ENDPOINTS="Voulez-vous ajouter des points de terminaison RPC personnalisés ? (y/n)"
            MSG_THANKS="Si ce script vous a aidé, n'oubliez pas de mettre un ⭐ sur GitHub 😉..."
            MSG_L1RN_RPC="Points de terminaison L1RN RPC disponibles :"
            MSG_SELECT_L1RN="Entrez les numéros des points de terminaison L1RN RPC à activer (séparés par des virgules, par exemple, 1,2) :"
            MSG_INVALID_SELECTION="Sélection invalide : %s. Ignoré."
            MSG_OUT_OF_RANGE="L'index %s est hors limites. Ignoré."
            MSG_NO_SELECTION="Aucune sélection valide. Veuillez sélectionner au moins un point de terminaison."
            MSG_ALCHEMY_API_KEY="Entrez votre clé API Alchemy :"
            MSG_CREATE_DIR="Création et navigation vers le répertoire t3rn..."
            MSG_DOWNLOAD_COMPLETE="Téléchargement terminé."
            MSG_NAVIGATE_BINARY="Navigation vers l'emplacement du binaire de l'exécuteur..."
            MSG_COLLECTED_INPUTS="Entrées et paramètres collectés :"
            MSG_NODE_TYPE_LABEL="Type de nœud :"
            MSG_ALCHEMY_API_KEY_LABEL="Clé API Alchemy :"
            MSG_GAS_VALUE_LABEL="Valeur du gaz :"
            MSG_RPC_ENDPOINTS_LABEL="Réseaux activés et points RPC:"
            MSG_WALLET_PRIVATE_KEY_LABEL="Clé privée du portefeuille :"
            MSG_FAILED_CREATE_DIR="Échec de la création ou de la navigation vers le répertoire t3rn. Sortie."
            MSG_FAILED_FETCH_TAG="Échec de la récupération de la dernière balise de version. Veuillez vérifier votre connexion Internet et réessayer."
            MSG_FAILED_DOWNLOAD="Échec du téléchargement de la dernière version. Veuillez vérifier l'URL et réessayer."
            MSG_FAILED_EXTRACT="Échec de l'extraction de l'archive. Veuillez vérifier le fichier et réessayer."
            MSG_FAILED_NAVIGATE="Échec de la navigation vers l'emplacement du binaire de l'exécuteur. Sortie."
            MSG_DELETE_T3RN_DIR="Suppression du répertoire t3rn existant..."
            MSG_DELETE_EXECUTOR_DIR="Suppression du répertoire executor existant..."
            MSG_DELETE_TAR_GZ="Suppression des fichiers tar.gz précédemment téléchargés..."
            MSG_EXTRACTION_COMPLETE="Extraction terminée."
            MSG_RUNNING_NODE="Lancement du nœud..."
            MSG_DRY_RUN_DELETE="[Dry-run] Les répertoires t3rn et executor existants seraient supprimés."
            MSG_DRY_RUN_CREATE_DIR="[Dry-run] Le répertoire t3rn serait créé et la navigation s'y ferait."
            MSG_DRY_RUN_NAVIGATE="[Dry-run] Navigation vers l'emplacement du binaire de l'exécuteur."
            MSG_DRY_RUN_RUN_NODE="[Dry-run] Le nœud serait lancé."
            MSG_ENTER_CUSTOM_RPC="Entrez les points de terminaison RPC personnalisés:"
            MSG_ARBT_RPC="Points de terminaison RPC Arbitrum Sepolia (par défaut : $DEFAULT_RPC_ENDPOINTS_ARBT)"
            MSG_BSSP_RPC="Points de terminaison RPC Base Sepolia (par défaut : $DEFAULT_RPC_ENDPOINTS_BSSP)"
            MSG_BLSS_RPC="Points de terminaison RPC Blast Sepolia (par défaut : $DEFAULT_RPC_ENDPOINTS_BLSS)"
            MSG_OPSP_RPC="Points de terminaison RPC Optimism Sepolia (par défaut : $DEFAULT_RPC_ENDPOINTS_OPSP)"
			MSG_AVAILABLE_NETWORKS="Réseaux disponibles :"
            MSG_ARBT_DESC="ARBT = arbitrum-sepolia"
            MSG_BSSP_DESC="BSSP = base-sepolia"
            MSG_OPSP_DESC="OPSP = optimism-sepolia"
            MSG_BLSS_DESC="BLSS = blast-sepolia"
            MSG_L2RN_ALWAYS_ENABLED="L2RN est toujours activé."
            MSG_ENTER_NETWORKS="Entrez les réseaux à activer (séparés par des virgules, ex: ARBT,BSSP,OPSP,BLSS ou Entrée/'all' pour tous) :"
            MSG_INVALID_NETWORK="Réseau invalide : %s. Veuillez entrer des réseaux valides."
			MSG_CHECKING_EXECUTOR="=== Vérification des processus executor en cours ==="
            MSG_KILLING_EXECUTOR="Processus executor en cours détecté. Arrêt pour éviter les conflits..."
            MSG_EXECUTOR_KILLED="Ancien processus executor arrêté avec succès."
            MSG_NO_EXECUTOR_RUNNING="Aucun processus executor en cours - prêt à continuer."
			MSG_WARNING="⚠️ AVERTISSEMENT : LORSQUE VOUS PARTAGEZ DES CAPTURES D'ÉCRAN DE CE SCRIPT EN RAISON D'UNE ERREUR, ASSUREZ-VOUS QUE VOS CLÉS PRIVÉES ET VOTRE CLÉ API ALCHEMY NE SONT PAS VISIBLES ! SINON, VOUS RISQUEZ DE PERDRE TOUS LES ACTIFS DE VOTRE PORTEFEUILLE OU DE COMPROMETTRE VOTRE ACCÈS API ! ⚠️"
			MSG_JQ_REQUIRED="jq est requis pour le traitement JSON. Installation de jq..."
            MSG_JQ_INSTALL_FAILED="Échec de l'installation de jq. Veuillez l'installer manuellement et réessayer."
            MSG_JQ_INSTALL_SUCCESS="jq installé avec succès."
			MSG_NODE_TYPE_OPTIONS="Sélectionnez le type de nœud :"
			MSG_API_MODE="1) Nœud API - Soumet des transactions directement via API"
			MSG_ALCHEMY_MODE="2) RPC Alchemy - Utilise des points de terminaison RPC gérés par Alchemy (clé API requise)"
			MSG_CUSTOM_MODE="3) RPC Personnalisé - Utilise des points de terminaison RPC publics/personnalisés (Alchemy non nécessaire)"
			MSG_API_MODE_DESC="Mode API : Soumission directe de transactions activée"
			MSG_ALCHEMY_MODE_DESC="Mode Alchemy : Utilisation des points de terminaison Alchemy pour RPC"
			MSG_CUSTOM_MODE_DESC="Mode RPC Personnalisé : Utilisation de points de terminaison publics/personnalisés"
			MSG_SELECT_NODE_TYPE="Entrez votre choix (1/2/3) : "
			MSG_INVALID_NODE_TYPE="Sélection de type de nœud invalide. Veuillez entrer 1, 2 ou 3."
            break
            ;;
        *)
            echo -e "${RED}$MSG_INVALID_LANG${NC}"
            ;;
    esac
done


# Step 0: Clean up previous installations
echo -e "${GREEN}$MSG_CLEANUP${NC}"
if $DRY_RUN; then
    echo -e "${ORANGE}$MSG_DRY_RUN_DELETE${NC}"
	sleep 1
else
    if [ -d "t3rn" ]; then
        echo -e "${ORANGE}$MSG_DELETE_T3RN_DIR${NC}"
        rm -rf t3rn
    fi
	
	sleep 1

    if [ -d "executor" ]; then
        echo -e "${ORANGE}$MSG_DELETE_EXECUTOR_DIR${NC}"
        rm -rf executor
    fi
	
	sleep 1
	
    if ls executor-linux-*.tar.gz 1> /dev/null 2>&1; then
        echo -e "${ORANGE}$MSG_DELETE_TAR_GZ${NC}"
        rm -f executor-linux-*.tar.gz
    fi
	
	sleep 1
fi

# Step 1: Create and navigate to t3rn directory
echo -e "${ORANGE}$MSG_CREATE_DIR${NC}"
if $DRY_RUN; then
    echo -e "${GREEN}$MSG_DRY_RUN_CREATE_DIR${NC}"
else
    mkdir -p t3rn
    cd t3rn || { echo -e "${RED}$MSG_FAILED_CREATE_DIR${NC}"; exit 1; }
fi

# Step 2.5: Version selection
echo -e "${GREEN}${MSG_VERSION_CHOICE}${NC}"
echo -e " ${ORANGE}${MSG_LATEST_OPTION}${NC}"
echo -e " ${ORANGE}${MSG_SPECIFIC_OPTION}${NC}"

while true; do
    read -p "$(echo -e "${GREEN}${MSG_SELECT_NODE_TYPE}${NC}")" VERSION_CHOICE
    
    case $VERSION_CHOICE in
        1)
            LATEST_TAG=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
            [ -z "$LATEST_TAG" ] && { echo -e "${RED}$MSG_FAILED_FETCH_TAG${NC}"; exit 1; }
            break
            ;;
        2)
            while true; do
                echo -e "${GREEN}${MSG_ENTER_VERSION}${NC}"
                read LATEST_TAG
                [[ "$LATEST_TAG" =~ ^v[0-9]+\.[0-9]+(\.[0-9]+)?$ ]] && break
                echo -e "${RED}${MSG_INVALID_VERSION_FORMAT}${NC}"
            done
            break
            ;;
        *)
            echo -e "${RED}${MSG_INVALID_VERSION_CHOICE}${NC}"
            ;;
    esac
done

# Step 2: Download the latest release
DOWNLOAD_URL="https://github.com/t3rn/executor-release/releases/download/$LATEST_TAG/executor-linux-$LATEST_TAG.tar.gz"
#download_file "$DOWNLOAD_URL" "executor-linux-$LATEST_TAG.tar.gz"
wget --progress=bar:force:noscroll "$DOWNLOAD_URL" -O "executor-linux-$LATEST_TAG.tar.gz"
if [ $? -ne 0 ]; then
    echo "${RED}$MSG_FAILED_DOWNLOAD${NC}"
	sleep 2
    exit 1
fi
echo -e "${GREEN}$MSG_DOWNLOAD_COMPLETE${NC}"
sleep 1

# Step 3: Extract the archive
echo -e "${ORANGE}$MSG_EXTRACT${NC}"
# extract_archive "executor-linux-$LATEST_TAG.tar.gz"
tar -xvzf "executor-linux-$LATEST_TAG.tar.gz"
if [ $? -ne 0 ]; then
    echo -e "${RED}$MSG_FAILED_EXTRACT${NC}"
	sleep 2
    exit 1
fi

echo -e "${GREEN}$MSG_EXTRACTION_COMPLETE${NC}"
sleep 1

# Step 4: Navigate to the executor binary location
echo -e "${ORANGE}$MSG_NAVIGATE_BINARY${NC}"
if $DRY_RUN; then
    echo -e "${GREEN}$MSG_DRY_RUN_DELETE${NC}"
	sleep 1
else
    mkdir -p executor/executor/bin
    cd executor/executor/bin || { echo -e "${RED}$MSG_FAILED_NAVIGATE${NC}"; exit 1; }
	sleep 1
fi

# Ask if the user wants to run an API node or RPC node
echo -e "${GREEN}$MSG_NODE_TYPE_OPTIONS${NC}"
echo -e " ${ORANGE}${MSG_API_MODE}${NC}"
echo -e " ${ORANGE}${MSG_ALCHEMY_MODE}${NC}"
echo -e " ${ORANGE}${MSG_CUSTOM_MODE}${NC}"

while true; do
    read -p "$(echo -e "${GREEN}${MSG_SELECT_NODE_TYPE}${NC}")" NODE_TYPE_CHOICE
    
    case $NODE_TYPE_CHOICE in
        1)
            NODE_TYPE="api"
            echo -e "${GREEN}${MSG_API_MODE_DESC}${NC}"
            export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=true
            export EXECUTOR_PROCESS_ORDERS_API_ENABLED=true
            break
            ;;
        2)
            NODE_TYPE="alchemy-rpc"
            echo -e "${GREEN}${MSG_ALCHEMY_MODE_DESC}${NC}"
            export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
            export EXECUTOR_PROCESS_ORDERS_API_ENABLED=false
            break
            ;;
        3)
            NODE_TYPE="custom-rpc"
            echo -e "${GREEN}${MSG_CUSTOM_MODE_DESC}${NC}"
            export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
            export EXECUTOR_PROCESS_ORDERS_API_ENABLED=false
            break
            ;;
        *)
            echo -e "${RED}${MSG_INVALID_NODE_TYPE}${NC}"
            ;;
    esac
done

# Ask for wallet private key (masked input)
echo -e "${GREEN}$MSG_PRIVATE_KEY${NC}"
WALLET_PRIVATE_KEY=$(ask_for_input "")

# Ask for Alchemy API key (masked input, if RPC node is selected)
if [[ "$NODE_TYPE" == "alchemy-rpc" ]]; then
    echo -e "${GREEN}$MSG_ALCHEMY_API_KEY${NC}"
    ALCHEMY_API_KEY=$(ask_for_input "")
elif [[ "$NODE_TYPE" == "custom-rpc" ]]; then
    echo -e "${ORANGE}${MSG_CUSTOM_RPC_WARNING}${NC}"
    sleep 2
fi

# Ask for gas value and validate it
while true; do
	echo -e "${GREEN}$MSG_GAS_VALUE${NC} "
    read GAS_VALUE
    if [[ "$GAS_VALUE" =~ ^[0-9]+$ ]] && (( GAS_VALUE >= 100 && GAS_VALUE <= 20000 )); then
        break
    else
        echo -e "${RED}$MSG_INVALID_GAS${NC}"
    fi
done

#Configure RPC endpoints
configure_rpc_endpoints() {
    case $NODE_TYPE in
        "alchemy-rpc")
            echo -e "${GREEN}Merging Alchemy endpoints...${NC}"
            RPC_ENDPOINTS_JSON=$(echo "$RPC_ENDPOINTS_JSON" | jq \
                --arg arbt "https://arb-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY" \
                --arg bast "https://base-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY" \
                --arg opst "https://opt-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY" \
                --arg blst "https://blast-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY" \
                '.arbt += [$arbt] | .bast += [$bast] | .opst += [$opst] | .blst += [$blst]')
            ;;

        "custom-rpc")
            echo -e "${GREEN}Using custom RPC endpoints only...${NC}"
            RPC_ENDPOINTS_JSON=$(echo "$RPC_ENDPOINTS_JSON" | jq 'del(.arbt, .bast, .opst, .blst)')
            ;;
    esac
}

# Execute configuration
configure_rpc_endpoints

# Set Node Environment
export ENVIRONMENT=testnet

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
DEFAULT_RPC_ENDPOINTS_JSON='{
  "l2rn": ["https://t3rn-b2n.blockpi.network/v1/rpc/public"],
  "arbt": ["https://arbitrum-sepolia.gateway.tenderly.co", "https://arbitrum-sepolia.drpc.org"],
  "bast": ["https://base-sepolia-rpc.publicnode.com", "https://base-sepolia.drpc.org"],
  "blst": ["https://sepolia.blast.io", "https://endpoints.omniatech.io/v1/blast/sepolia/public"],
  "opst": ["https://sepolia.optimism.io", "https://optimism-sepolia.gateway.tenderly.co"],
  "unit": ["https://unichain-sepolia.drpc.org", "https://unichain-sepolia-rpc.publicnode.com"],
  "mont": ["https://testnet-rpc.monad.xyz"]
}'

# Initialize RPC_ENDPOINTS_JSON with defaults
RPC_ENDPOINTS_JSON="$DEFAULT_RPC_ENDPOINTS_JSON"

# Extract default endpoints from JSON
DEFAULT_RPC_ENDPOINTS_ARBT=$(echo "$DEFAULT_RPC_ENDPOINTS_JSON" | jq -r '.arbt[0]')
DEFAULT_RPC_ENDPOINTS_BSSP=$(echo "$DEFAULT_RPC_ENDPOINTS_JSON" | jq -r '.bast[0]')
DEFAULT_RPC_ENDPOINTS_BLSS=$(echo "$DEFAULT_RPC_ENDPOINTS_JSON" | jq -r '.blst[0]')
DEFAULT_RPC_ENDPOINTS_OPSP=$(echo "$DEFAULT_RPC_ENDPOINTS_JSON" | jq -r '.opst[0]')
DEFAULT_RPC_ENDPOINTS_UNIT=$(echo "$DEFAULT_RPC_ENDPOINTS_JSON" | jq -r '.unit[0]')
DEFAULT_RPC_ENDPOINTS_L2RN=$(echo "$DEFAULT_RPC_ENDPOINTS_JSON" | jq -r '.l2rn[0]')


# Ask if the user wants to add custom RPC endpoints or use default ones
echo -e "${GREEN}$MSG_RPC_ENDPOINTS: ${NC}" 
read CUSTOM_RPC

if [[ "$CUSTOM_RPC" =~ ^[Yy]$ ]]; then
    echo -e "${ORANGE}$MSG_ENTER_CUSTOM_RPC${NC}"
    
    declare -A rpc_map=(
        ["arbt"]="Arbitrum Sepolia"
        ["bast"]="Base Sepolia"
        ["blst"]="Blast Sepolia"
        ["opst"]="Optimism Sepolia"
        ["unit"]="Unichain Sepolia"  # Added
        ["l2rn"]="L2RN"
    )

    RPC_ENDPOINTS_JSON="{"
    for network in "${!rpc_map[@]}"; do
        echo -e "${GREEN}Enter RPC endpoints for ${rpc_map[$network]} (comma-separated):${NC}"
        read -p "> " endpoints
        if [ -n "$endpoints" ]; then
            RPC_ENDPOINTS_JSON+="\"$network\": $(parse_rpc_input "$endpoints"),"
        else
            default_value=$(echo "$DEFAULT_RPC_ENDPOINTS_JSON" | jq -c ".$network")  # Fixed variable
            RPC_ENDPOINTS_JSON+="\"$network\": $default_value,"
        fi
    done
    RPC_ENDPOINTS_JSON="${RPC_ENDPOINTS_JSON%,}}"
else
    RPC_ENDPOINTS_JSON="$DEFAULT_RPC_ENDPOINTS_JSON"  # Fixed variable
fi


# Validate JSON structure
if ! jq empty <<< "$RPC_ENDPOINTS_JSON"; then
    echo -e "${RED}Invalid JSON. Using defaults.${NC}"
    RPC_ENDPOINTS_JSON="$DEFAULT_RPC_ENDPOINTS_JSON"
fi

# Minify JSON
export RPC_ENDPOINTS=$(echo "$RPC_ENDPOINTS_JSON" | jq -c .)

# Build the final RPC_ENDPOINTS_L1RN string and ensure it gets appended properly
SELECTED_URLS=()
for i in "${VALID_INDICES[@]}"; do
    SELECTED_URLS+=("${L1RN_RPC_OPTIONS[$i]}")
done

# Ensure default or user selection gets assigned
if [ ${#SELECTED_URLS[@]} -eq 0 ]; then
    RPC_ENDPOINTS_L1RN="https://brn.calderarpc.com/http,https://brn.rpc.caldera.xyz/"
else
    RPC_ENDPOINTS_L1RN=$(IFS=,; echo "${SELECTED_URLS[*]}")
fi

# Configure RPC endpoints based on node type
if [[ "$NODE_TYPE" == "rpc" ]]; then
  echo -e "${GREEN}Adding Alchemy RPC endpoints...${NC}"
  
  # Safely merge Alchemy endpoints with existing ones
  if ! RPC_ENDPOINTS_JSON=$(echo "$RPC_ENDPOINTS_JSON" | jq \
    --arg arbt "https://arb-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY" \
    --arg bast "https://base-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY" \
    --arg opst "https://opt-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY" \
    --arg blst "https://blast-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY" \
    --arg unit "https://unichain-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY" \
    '.arbt = (.arbt + [$arbt]) |
     .bast = (.bast + [$bast]) |
     .opst = (.opst + [$opst]) |
     .blst = (.blst + [$blst]) |
     .unit = (.unit + [$unit])' ); then
    echo -e "${RED}Failed to merge Alchemy endpoints. Invalid JSON structure.${NC}"
    exit 1
fi

  # Validate the final JSON
  if ! echo "$RPC_ENDPOINTS_JSON" | jq empty; then
    echo -e "${RED}Invalid JSON structure after modifications:${NC}"
    echo "$RPC_ENDPOINTS_JSON"
    exit 1
  fi
fi

# Minify JSON with validation
if ! RPC_ENDPOINTS=$(echo "$RPC_ENDPOINTS_JSON" | jq -c .); then
  echo -e "${RED}Failed to minify RPC endpoints JSON. Structure:${NC}"
  echo "$RPC_ENDPOINTS_JSON"
  exit 1
fi
export RPC_ENDPOINTS

# ASK FOR WALLET PRIVATE KEY
export PRIVATE_KEY_LOCAL=$WALLET_PRIVATE_KEY
RPC_ENDPOINTS_JSON=$(echo "$RPC_ENDPOINTS_JSON" | jq -c .)
export RPC_ENDPOINTS="$RPC_ENDPOINTS_JSON"

# Ask user which network should be enabled
echo -e "${GREEN}$MSG_AVAILABLE_NETWORKS${NC}"
echo -e "${ORANGE}ARBT = arbitrum-sepolia${NC}"
echo -e "${ORANGE}BAST = base-sepolia${NC}"
echo -e "${ORANGE}BLST = blast-sepolia${NC}"
echo -e "${ORANGE}OPST = optimism-sepolia${NC}"
echo -e "${ORANGE}UNIT = unichain-sepolia${NC}"
echo -e "${ORANGE}MONT = monad-testnet${NC}"
echo -e "${RED}$MSG_L2RN_ALWAYS_ENABLED${NC}"
echo -e "${GREEN}Want to add a custom network? Enter 'custom'${NC}"

ENABLED_NETWORKS="l2rn"  # l2rn is now always enabled as base layer
while true; do
    read -p "$(echo -e "${GREEN}Enter networks to enable (comma-separated):\n[ARBT, BAST, BLST, OPST, UNIT] or 'all':${NC} ")" USER_NETWORKS
    if [[ -z "$USER_NETWORKS" || "$USER_NETWORKS" =~ ^[Aa][Ll][Ll]$ ]]; then
        ENABLED_NETWORKS="$ENABLED_NETWORKS,arbitrum-sepolia,base-sepolia,blast-sepolia,optimism-sepolia,unichain-sepolia"
        break
    else
        IFS=',' read -r -a networks <<< "$USER_NETWORKS"
        valid=true
        for network in "${networks[@]}"; do
            case "$network" in
                ARBT)
                    ENABLED_NETWORKS="$ENABLED_NETWORKS,arbitrum-sepolia"
                    ;;
                BAST)
                    ENABLED_NETWORKS="$ENABLED_NETWORKS,base-sepolia"
                    ;;
                BLST)
                    ENABLED_NETWORKS="$ENABLED_NETWORKS,blast-sepolia"
                    ;;
                OPST)
                    ENABLED_NETWORKS="$ENABLED_NETWORKS,optimism-sepolia"
                    ;;
                UNIT)
                    ENABLED_NETWORKS="$ENABLED_NETWORKS,unichain-sepolia"
                    ;;
				 MONT)
					ENABLED_NETWORKS="$ENABLED_NETWORKS,monad-testnet"
            ;;
				custom)
					echo -e "${GREEN}Enter custom network name (e.g., mynetwork):${NC}"
					read -p "> " CUSTOM_NET_NAME
					echo -e "${GREEN}Enter RPC endpoints for $CUSTOM_NET_NAME (comma-separated):${NC}"
					read -p "> " CUSTOM_RPC_ENDPOINTS
					# Add to RPC_ENDPOINTS_JSON
					RPC_ENDPOINTS_JSON=$(echo "$RPC_ENDPOINTS_JSON" | jq \
						--arg name "$CUSTOM_NET_NAME" \
						--argjson endpoints "$(parse_rpc_input "$CUSTOM_RPC_ENDPOINTS")" \
						'. + {($name): $endpoints}')
					ENABLED_NETWORKS="$ENABLED_NETWORKS,$CUSTOM_NET_NAME"
					;;
					*)
                    echo -e "${RED}Invalid network: $network. Valid options: ARBT, BAST, BLST, OPST, UNIT, MONT${NC}"
                    valid=false
                    break
                    ;;
            esac
        done
        $valid && break
    fi
done
export ENABLED_NETWORKS

# Export RPC endpoints
export RPC_ENDPOINTS_ARBT
export RPC_ENDPOINTS_BSSP
export RPC_ENDPOINTS_BLSS
export RPC_ENDPOINTS_OPSP
export RPC_ENDPOINTS_L1RN
export EXECUTOR_MAX_L3_GAS_PRICE=$GAS_VALUE

# Display the collected inputs and settings (for verification)
echo -e "${GREEN}$MSG_COLLECTED_INPUTS${NC}"
echo -e "${ORANGE}$MSG_NODE_TYPE_LABEL $NODE_TYPE${NC}"
if [[ "$NODE_TYPE" == "rpc" ]]; then
    # Mask the API key for display
    MASKED_API_KEY="${ALCHEMY_API_KEY:0:6}******${ALCHEMY_API_KEY: -6}"
    echo -e "${ORANGE}$MSG_ALCHEMY_API_KEY_LABEL${NC} ${BLUE}$MASKED_API_KEY${NC}"
fi

# Mask the private key for display
MASKED_PRIVATE_KEY="${WALLET_PRIVATE_KEY:0:6}******${WALLET_PRIVATE_KEY: -6}"
echo -e "${ORANGE}$MSG_WALLET_PRIVATE_KEY_LABEL${NC} ${BLUE}$MASKED_PRIVATE_KEY${NC}"
echo -e "${ORANGE}$MSG_GAS_VALUE_LABEL${NC} ${BLUE}$GAS_VALUE${NC}"
echo -e "${ORANGE}EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API:${NC} ${BLUE}$EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API${NC}"
echo -e "${ORANGE}EXECUTOR_PROCESS_ORDERS_API_ENABLED:${NC} ${BLUE}$EXECUTOR_PROCESS_ORDERS_API_ENABLED${NC}"
echo -e "${ORANGE}NODE_ENV:${NC} ${BLUE}$NODE_ENV${NC}"
echo -e "${ORANGE}LOG_LEVEL:${NC} ${BLUE}$LOG_LEVEL${NC}"
echo -e "${ORANGE}LOG_PRETTY:${NC} ${BLUE}$LOG_PRETTY${NC}"
echo -e "${ORANGE}EXECUTOR_PROCESS_BIDS_ENABLED:${NC} ${BLUE}$EXECUTOR_PROCESS_BIDS_ENABLED${NC}"
echo -e "${ORANGE}EXECUTOR_PROCESS_ORDERS_ENABLED:${NC} ${BLUE}$EXECUTOR_PROCESS_ORDERS_ENABLED${NC}"
echo -e "${ORANGE}EXECUTOR_PROCESS_CLAIMS_ENABLED:${NC} ${BLUE}$EXECUTOR_PROCESS_CLAIMS_ENABLED${NC}"
echo -e "${GREEN}$MSG_RPC_ENDPOINTS_LABEL${NC}"

# Check which networks are enabled and display their RPC endpoints
if [[ "$ENABLED_NETWORKS" == *"arbitrum-sepolia"* ]]; then
    echo -e "${ORANGE}ARBT:${NC} ${BLUE}$RPC_ENDPOINTS_ARBT${NC}"
fi
if [[ "$ENABLED_NETWORKS" == *"base-sepolia"* ]]; then
    echo -e "${ORANGE}BSSP:${NC} ${BLUE}$RPC_ENDPOINTS_BSSP${NC}"
fi
if [[ "$ENABLED_NETWORKS" == *"blast-sepolia"* ]]; then
    echo -e "${ORANGE}BLSS:${NC} ${BLUE}$RPC_ENDPOINTS_BLSS${NC}"
fi
if [[ "$ENABLED_NETWORKS" == *"optimism-sepolia"* ]]; then
    echo -e "${ORANGE}OPSP:${NC} ${BLUE}$RPC_ENDPOINTS_OPSP${NC}"
fi
if [[ "$ENABLED_NETWORKS" == *"l1rn"* ]]; then
    echo -e "${ORANGE}L1RN:${NC} ${BLUE}$RPC_ENDPOINTS_L1RN${NC}"
fi
if [[ "$ENABLED_NETWORKS" == *"blast-sepolia"* ]]; then
    echo -e "${ORANGE}BLST:${NC} ${BLUE}$RPC_ENDPOINTS_BLSS${NC}"
fi
if [[ "$ENABLED_NETWORKS" == *"unichain-sepolia"* ]]; then
    echo -e "${ORANGE}UNIT:${NC} ${BLUE}$RPC_ENDPOINTS_UNIT${NC}"
fi

if [[ "$ENABLED_NETWORKS" == *"monad-testnet"* ]]; then
    echo -e "${ORANGE}MONT:${NC} ${BLUE}$(echo "$RPC_ENDPOINTS_JSON" | jq -r '.mont[0]')${NC}"
fi

# Display custom networks (not in predefined list)
PREDEFINED_NETWORKS=("arbitrum-sepolia" "base-sepolia" "blast-sepolia" "optimism-sepolia" "unichain-sepolia" "monad-testnet" "l2rn")
for network in $(echo "$ENABLED_NETWORKS" | tr ',' '\n'); do
    if [[ ! " ${PREDEFINED_NETWORKS[@]} " =~ " ${network} " ]]; then
        echo -e "${ORANGE}${network}:${NC} ${BLUE}$(echo "$RPC_ENDPOINTS_JSON" | jq -r ".\"$network\"[0]")${NC}"
    fi
done

# Step 5: Proceed with the installation or other setup steps
echo -e "${GREEN}$MSG_THANKS${NC}"
sleep 3

if $DRY_RUN; then
    echo -e "${GREEN}$MSG_DRY_RUN_RUN_NODE${NC}"
else
    echo -e "\n${ORANGE}$MSG_CHECKING_EXECUTOR${NC}"
	kill_running_executor
	sleep 1

    echo -e "${BLUE}$MSG_RUNNING_NODE${NC}"
    ./executor
fi
