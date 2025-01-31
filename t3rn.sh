#!/bin/bash
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[38;5;214m'
NC='\033[0m' # No Color

echo -e "${GREEN}Join our Telegram channel: https://t.me/kriptoqapik${NC}"
echo -e "${ORANGE}-----------------------------------------------------${NC}"
echo -e "${GREEN}Get free 20€ credit for VPS on Hetzner: https://hetzner.cloud/?ref=mjjaxNOJxUW1${NC}"
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
}

# Language selection
while true; do
    # Define MSG_INVALID_LANG for all cases
    MSG_INVALID_LANG="Invalid language code. Please try again."

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
            MSG_INVALID_LANG="Invalid language code. Please try again."
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
            MSG_RPC_ENDPOINTS_LABEL="RPC Endpoints:"
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
            break
            ;;
        az)
            MSG_INVALID_LANG="Yanlış dil kodu. Yenidən cəhd edin."
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
            MSG_RPC_ENDPOINTS_LABEL="RPC Endpointləri:"
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
            break
            ;;
        ru)
            MSG_INVALID_LANG="Неверный код языка. Пожалуйста, попробуйте снова."
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
            MSG_RPC_ENDPOINTS_LABEL="RPC-точки:"
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
            MSG_RPC_ENDPOINTS_LABEL="RPC-Endpunkte:"
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
            break
            ;;
        id)
            MSG_INVALID_LANG="Kode bahasa tidak valid. Silakan coba lagi."
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
            MSG_RPC_ENDPOINTS_LABEL="Endpoint RPC:"
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
            break
            ;;
        fr)
            MSG_INVALID_LANG="Code de langue invalide. Veuillez réessayer."
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
            MSG_RPC_ENDPOINTS_LABEL="Points de terminaison RPC :"
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
            break
            ;;
        *)
            echo -e "${RED}$MSG_INVALID_LANG${NC}"
            ;;
    esac
done


# Step 0: Clean up previous installations
echo -e "${BLUE}$MSG_CLEANUP${NC}"
if $DRY_RUN; then
    echo -e "${GREEN}$MSG_DRY_RUN_DELETE${NC}"
	sleep 1
else
    if [ -d "t3rn" ]; then
        echo -e "${BLUE}$MSG_DELETE_T3RN_DIR${NC}"
        rm -rf t3rn
    fi
	
	sleep 1

    if [ -d "executor" ]; then
        echo -e "${BLUE}$MSG_DELETE_EXECUTOR_DIR${NC}"
        rm -rf executor
    fi
	
	sleep 1
	
    if ls executor-linux-*.tar.gz 1> /dev/null 2>&1; then
        echo -e "${BLUE}$MSG_DELETE_TAR_GZ${NC}"
        rm -f executor-linux-*.tar.gz
    fi
	
	sleep 1
fi

# Step 1: Create and navigate to t3rn directory
echo -e "${BLUE}echo -e "${BLUE}$MSG_CREATE_DIR${NC}"${NC}"
if $DRY_RUN; then
    echo -e "${GREEN}$MSG_DRY_RUN_CREATE_DIR${NC}"
else
    mkdir -p t3rn
    cd t3rn || { echo -e "${RED}$MSG_FAILED_CREATE_DIR${NC}"; exit 1; }
fi

# Step 2: Download the latest release
echo -e "${BLUE}$MSG_DOWNLOAD${NC}"
LATEST_TAG=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
if [ -z "$LATEST_TAG" ]; then
    echo -e "${RED}$MSG_FAILED_FETCH_TAG${NC}"
	sleep 2
    exit 1
fi

DOWNLOAD_URL="https://github.com/t3rn/executor-release/releases/download/$LATEST_TAG/executor-linux-$LATEST_TAG.tar.gz"
download_file "$DOWNLOAD_URL" "executor-linux-$LATEST_TAG.tar.gz"
wget --progress=bar:force:noscroll "$DOWNLOAD_URL" -O "executor-linux-$LATEST_TAG.tar.gz"
if [ $? -ne 0 ]; then
    echo "${RED}$MSG_FAILED_DOWNLOAD${NC}"
	sleep 2
    exit 1
fi
echo -e "${GREEN}$MSG_DOWNLOAD_COMPLETE${NC}"
sleep 1

# Step 3: Extract the archive
echo -e "${BLUE}$MSG_EXTRACT${NC}"
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
echo -e "${BLUE}$MSG_NAVIGATE_BINARY${NC}"
if $DRY_RUN; then
    echo -e "${GREEN}$MSG_DRY_RUN_DELETE${NC}"
	sleep 1
else
    mkdir -p executor/executor/bin
    cd executor/executor/bin || { echo -e "${RED}$MSG_FAILED_NAVIGATE${NC}"; exit 1; }
	sleep 1
fi

# Ask if the user wants to run an API node or RPC node
while true; do
    printf "${GREEN}%s${NC} " "$MSG_NODE_TYPE"
    read NODE_TYPE
    case $NODE_TYPE in
        api|rpc) break ;;
        *) echo -e "${RED}$MSG_INVALID_INPUT${NC}" ;;
    esac
done

# Ask for wallet private key (visible input)
echo -e "${GREEN}$MSG_PRIVATE_KEY${NC} "
WALLET_PRIVATE_KEY=$(ask_for_input "")

# Ask for Alchemy API key (if RPC node is selected)
if [[ "$NODE_TYPE" == "rpc" ]]; then
    echo -e "${GREEN}$MSG_ALCHEMY_API_KEY${NC} "
    ALCHEMY_API_KEY=$(ask_for_input "")
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
echo -e "${GREEN}$MSG_RPC_ENDPOINTS: ${NC}" 
read CUSTOM_RPC
if [[ "$CUSTOM_RPC" =~ ^[Yy]$ ]]; then
    echo -e "${ORANGE}$MSG_ENTER_CUSTOM_RPC${NC}"
    
    echo -e "${GREEN}$MSG_ARBT_RPC${NC}"
    RPC_ENDPOINTS_ARBT=$(ask_for_input "")

    echo -e "${GREEN}$MSG_BSSP_RPC${NC}"
    RPC_ENDPOINTS_BSSP=$(ask_for_input "")

    echo -e "${GREEN}$MSG_BLSS_RPC${NC}"
    RPC_ENDPOINTS_BLSS=$(ask_for_input "")

    echo -e "${GREEN}$MSG_OPSP_RPC${NC}"
    RPC_ENDPOINTS_OPSP=$(ask_for_input "")
	
    # Set custom flags for RPC only nodes to improve requests and bidding process
    export EXECUTOR_PROCESS_BIDS_ENABLED=true
	export EXECUTOR_ENABLE_BIDDING_PROCESSING=true
	export EXECUTOR_PROCESS_ORDERS_API_ENABLED=true
    # Resend failed claims request
    export EXECUTOR_RESEND_FAILED_CLAIMS=true

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

# Configure L1RN RPC endpoints (user selection)
echo -e "${GREEN}$MSG_L1RN_RPC${NC}"
L1RN_RPC_OPTIONS=(
    "https://brn.calderarpc.com/http"
    "https://brn.rpc.caldera.xyz/"
)

# Display available options
for i in "${!L1RN_RPC_OPTIONS[@]}"; do
    echo "$((i+1)). ${L1RN_RPC_OPTIONS[$i]}"
done

# Validate user input
while true; do
    echo -e "${ORANGE}$MSG_SELECT_L1RN: ${NC}" 
	read SELECTED_L1RN
    IFS=',' read -ra SELECTED_INDICES <<< "$SELECTED_L1RN"
    VALID_INDICES=()
    for index in "${SELECTED_INDICES[@]}"; do
        index=$(echo "$index" | tr -d ' ')
        if [[ ! "$index" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}$(printf "$MSG_INVALID_SELECTION" "$index")${NC}"
            continue
        fi
        adjusted_index=$((index - 1))
        if (( adjusted_index >= 0 && adjusted_index < ${#L1RN_RPC_OPTIONS[@]} )); then
            VALID_INDICES+=("$adjusted_index")
        else
            echo -e "${RED}$(printf "$MSG_OUT_OF_RANGE" "$index")${NC}"
        fi
    done
    if [ ${#VALID_INDICES[@]} -eq 0 ]; then
        echo -e "${RED}$MSG_NO_SELECTION${NC}"
    else
        break
    fi
done

# Build the final RPC_ENDPOINTS_L1RN string
SELECTED_URLS=()
for i in "${VALID_INDICES[@]}"; do
    SELECTED_URLS+=("${L1RN_RPC_OPTIONS[$i]}")
done
RPC_ENDPOINTS_L1RN=$(IFS=,; echo "${SELECTED_URLS[*]}")

# Configure RPC endpoints based on node type
if [[ "$NODE_TYPE" == "rpc" ]]; then
    # Update RPC endpoints with Alchemy API key
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
echo -e "${ORANGE}$MSG_GAS_VALUE_LABEL $GAS_VALUE${NC}"
echo -e "${ORANGE}EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API: $EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API${NC}"
echo -e "${ORANGE}EXECUTOR_PROCESS_ORDERS_API_ENABLED: $EXECUTOR_PROCESS_ORDERS_API_ENABLED${NC}"
echo -e "${ORANGE}NODE_ENV: $NODE_ENV${NC}"
echo -e "${ORANGE}LOG_LEVEL: $LOG_LEVEL${NC}"
echo -e "${ORANGE}LOG_PRETTY: $LOG_PRETTY${NC}"
echo -e "${ORANGE}EXECUTOR_PROCESS_BIDS_ENABLED: $EXECUTOR_PROCESS_BIDS_ENABLED${NC}"
echo -e "${ORANGE}EXECUTOR_PROCESS_ORDERS_ENABLED: $EXECUTOR_PROCESS_ORDERS_ENABLED${NC}"
echo -e "${ORANGE}EXECUTOR_PROCESS_CLAIMS_ENABLED: $EXECUTOR_PROCESS_CLAIMS_ENABLED${NC}"
echo -e "${ORANGE}$MSG_RPC_ENDPOINTS_LABEL${NC}"
echo -e "${ORANGE}ARBT: $RPC_ENDPOINTS_ARBT${NC}"
echo -e "${ORANGE}BSSP: $RPC_ENDPOINTS_BSSP${NC}"
echo -e "${ORANGE}BLSS: $RPC_ENDPOINTS_BLSS${NC}"
echo -e "${ORANGE}OPSP: $RPC_ENDPOINTS_OPSP${NC}"
echo -e "${ORANGE}L1RN: $RPC_ENDPOINTS_L1RN${NC}"

# Step 5: Proceed with the installation or other setup steps
echo -e "${GREEN}$MSG_THANKS${NC}"
sleep 3

if $DRY_RUN; then
    echo -e "${GREEN}$MSG_DRY_RUN_RUN_NODE${NC}"
else
    echo -e "${BLUE}$MSG_RUNNING_NODE${NC}"
    ./executor
fi
