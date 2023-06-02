
# DEPRECATED [deta Liquidator]

Bot to automatically liquidate undercollateralized and expired deta accounts.

## Usage

### Docker

Requires a running [docker](https://docker.com) engine.

```
docker run \
  -e WALLET_ADDRESS=0x2c7536E3605D9C16a7a3D7b1898e529396a65c23 \
  -e WALLET_PRIVATE_KEY=0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318 \
  -e ETHEREUM_NODE_URL=https://eth-mainnet.alchemyapi.io/v2/YOUR_ALCHEMY_KEY \
  -e SOLO_LIQUIDATIONS_ENABLED=true \
  -e SOLO_EXPIRATIONS_ENABLED=false \
  detaprotocol/liquidator
```

## Overview

This service will automatically liquidate undercollateralized and/or expired accounts on deta.

This bot works for Solo (Margin-Trading) accounts. Use the envvars `SOLO_LIQUIDATIONS_ENABLED`, `SOLO_EXPIRATIONS_ENABLED` to control what kind of liquidations to perform.

**Liquidations on deta happen internally between Accounts, so you will need an already-funded deta Account to use this liquidator bot. If you use the default of `SOLO_ACCOUNT_NUMBER=0`, you can fund your deta Margin (Solo) Account on [margin.deta.exchange](https://margin.deta.exchange).**

Successfully liquidating Accounts will modify your deta Account balances. You can liquidate assets you do not have in your Account provided you have another asset as collateral, which will just cause your deta Account Balance to go negative in that asset.

### Solo Liquidations
Liquidations on Solo reward a 5% spread on top of the current oracle prices for the assets being liquidated and used as collateral. Example:

Undercollateralized Account:
```
+2 ETH
-350 DAI
```

Liquidator Account:
```
+100 ETH
-1000 DAI
```

Oracle Prices:
```
ETH Oracle Price: $200
DAI Oracle Price: $1
```

Fully liquidating this account would cause 350 DAI to be paid to zero out its balance, and would reward `350 DAI * ($1/DAI / $200/ETH) * 1.05 = 1.8375 ETH` as payout. After the liquidation the account balances would be:


Undercollateralized Account:
```
+0.1625 ETH
0 DAI
```

Liquidator Account:
```
+101.8375 ETH
-1350 DAI
```

## Configuration

### Environment Variables

|ENV Variable|Description|
|-|-|
|WALLET_ADDRESS|**REQUIRED** Ethereum address of the deta account owner that will do the liquidations
|WALLET_PRIVATE_KEY|**REQUIRED** Ethereum private key the deta account owner that will do the liquidations. Make sure that "0x" is at the start of it (MetaMask exports private keys without it).|
|NETWORK_ID|Ethereum Network ID|
|ETHEREUM_NODE_URL|**REQUIRED** The URL of the Ethereum node to use (e.g. an [Alchemy](https://alchemy.com/?r=99314874-10ab-44f3-9070-9abd86f4388d) or [Infura](https://infura.io/) endpoint)|
|LIQUIDATION_KEY_EXPIRATION_SEC|Amount of time in seconds to wait before trying to liquidate the same account again|300|
|GAS_STATION_URL|URL of the gas station API to use|
|GAS_PRICE_MULTIPLIER|How much to multiply the `fast` gas price by when sending transactions|
|GAS_PRICE_UPDATE_FREQUENCY_SEC|How frequently to update the gas price|
|SOLO_LIQUIDATIONS_ENABLED|true or false - whether to liquidate solo accounts (true by default)|
|SOLO_EXPIRATIONS_ENABLED|true or false - whether to liquidate expired accounts (false by default)|
|SOLO_COLLATERAL_PREFERENCES|List of preferences for which collateral markets to receive first when liquidating|
|SOLO_OWED_PREFERENCES|List of preferences for which markets to liquidate first on an account when liquidating|
|SOLO_ACCOUNT_NUMBER|The deta account number to use for the liquidating account. If you're not sure what this is, use 0. This will show up on [trade.deta.exchange/account](https://trade.deta.exchange/account) if you connect with the same wallet.|
|SOLO_MIN_ACCOUNT_COLLATERALIZATION|The desired minimum collateralization of the liquidator account after completing a liquidation. Prevents the liquidator account from being at risk of being liquidated itself if the price of assets continues to move in some direction. Higher values are safer. e.g. 0.5 = 150% collateralization|
|SOLO_MIN_OVERHEAD_VALUE|If you can liquidate less than this amount of value before hitting `SOLO_MIN_ACCOUNT_COLLATERALIZATION`, then don't liquidate. (1 USD = 1e36)|
|SOLO_EXPIRED_ACCOUNT_DELAY_SECONDS|How long to wait before liquidating expired accounts. The spread for liquidating expired accounts ramps up linearly from 0% to 5% over 1 hour.|
|ACCOUNT_POLL_INTERVAL_MS|How frequently to poll for liquidatable accounts|
|MARKET_POLL_INTERVAL_MS|How frequently to poll for market updates|
