# 👉 T3RN V2 Incentivized Executor Node multilingual interactive easy installation script


## 👉 Get free 20€ credit for Hetzner Cloud VPS 💻 :
[https://www.hetzner.cloud/](https://hetzner.cloud/?ref=mjjaxNOJxUW1)


## 👉 Get free ALCHEMY API KEY for RPC 🔗:
[https://www.alchemy.com/](https://alchemy.com/?r=Dc3MDc2NzI5MjYwN)
      
To use certain features of this script, you may need an Alchemy API key. Follow these steps to get one:
1. Visit the Alchemy website.
2. Sign up for an account or sign in if you already have one.
3. Create a new app:
• Go to the “Apps” section of your dashboard.
• Click “Create App” and fill in the required details (e.g. app name, description, and network).
4. Once the app is successfully created, you will see the API key in the app details.
5. Copy the API key and use it as needed in your script.

      
  
👉 Official [Alchemy API Documentation](https://docs.alchemy.com/docs/alchemy-quickstart-guide)

👉 Official [T3RN Binary Setup Doumentation](https://docs.t3rn.io/executor/become-an-executor/binary-setup)


## ⚠️ Important Notes

T3RN Swap and earn BRN [https://bridge.t1rn.io](https://bridge.t1rn.io)

Check Executor [https://bridge.t1rn.io/explorer/orders](https://bridge.t1rn.io/explorer/orders)

BRN blockchain explorer [https://brn.explorer.caldera.xyz](https://brn.explorer.caldera.xyz/)

## Minimum 10 ETH on each chain is recommended to catch some bid and at least 1 BRN for fees (mandatory!).

## Bridge:

🔴 SEPO to ARB SEPO : [Arbitrum Official Bridge](https://bridge.arbitrum.io/?destinationChain=arbitrum-sepolia&sourceChain=sepolia)

🔴 SEPO to BASE, UNICHAIN and other Superchain SEPO : [SuperBridge](https://superbridge.app/base-sepolia)

🔴 SEPO to BLAST SEPO : send Sepolia ETH to one of these addresses (***1st one is recommended***) to get ETH on Blast Sepolia: ***0xc644cc19d2A9388b71dd1dEde07cFFC73237Dca8*** or ***0xDeDa8D3CCf044fE2A16217846B6e1f1cfD8e122f***

## Faucet list:

🔴 https://faucet.quicknode.com/arbitrum/sepolia

🔴 https://faucets.chain.link/arbitrum-sepolia

🔴 https://bwarelabs.com/faucets/arbitrum-sepolia

🔴 https://www.alchemy.com/faucets/ethereum-sepolia

🔴 https://docs.metamask.io/developer-tools/faucet/

🔴 https://cloud.google.com/application/web3/faucet/ethereum/sepolia

ℹ️ You can also buy Sepolia ETH from [TestnetBridge](https://testnetbridge.com/sepolia) if you want to start quickly. 💡Arbitrum and OP networks gives best rates💡



## 👉 Official  [Discord Community](https://discord.gg/h8qeqJTXR4)



## ⚙️ This script will offer 3 installation modes:

### ℹ️ API Node = executor node will process requests from API and doesn't need to have a private Alchemy RPC points.

### ℹ️ Alchemy RPC = executor will ask for Alchemy API key and will process only orders from RPC requests.

### ℹ️ Custom RPC = It's same as RPC mode, but instead of Alchemy API, uses public RPC points.

## ⚠️ Additionally script will ask if you want to add custom public RPC nodes. If you say NO then it will use default public RPCs which already integrated into script

- 🌐 Select your language
  
- ✅ Select a node type

- 🔐 Input required details

- 🟠 Set Gwei, by default gwei is set for 200

- 🏃‍♂️‍➡️🏃‍♂️‍➡️🏃‍♂️‍➡️ Let it run! 🏃‍♂️‍➡️🏃‍♂️‍➡️🏃‍♂️‍➡️

- ## 📺 Watch the video to see how it works 👇


👉👉👉 [T3RN Network v1 testnet interactive node installation.](https://www.youtube.com/watch?v=jNiqmzZ7IMk) 👈👈👈



## ✨ AUTO INSTALLATION

## ⚙️ Run this script to install executor node?
Update system :
```bash
sudo apt update && sudo apt upgrade -y
```

Install required packages:
```bash
sudo apt install curl screen jq -y
```

If you were using old version of this script, first delete it:
```bash
find ~/ -type f -name '*t3rn*' -exec rm -f {} \;
```

Kill old screens if you want:
```bash
killall screen
```

Run a screen so node could work on the background if you logout or close the terminal:
```bash
screen -S t3rn
```

Get latest t3rn.sh file:

```bash
wget https://raw.githubusercontent.com/voogarix/t3rn-/refs/heads/main/t3rn.sh
```

Give a permission and run the node:

```bash
chmod +x t3rn.sh && ./t3rn.sh
```

## 🆕 Test this script without installation

### Now you can test this script without installing or modifying any existing files/folders by using dry-run flag:
```bash
./t3rn.sh --dry-run
```
### If you want to debug, use --verbose flag:
```bash
./t3rn.sh --verbose
```

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check [issues page](https://github.com/voogarix/t3rn-/issues) if you want to contribute.


Enjoy using the Automation installation! If you have any questions or run into any issues, please don't hesitate to reach out or open an issue on GitHub.! ✨
