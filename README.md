# CronDex - Cross-chain yield aggregator

## Background

One of the main reasons why DeFi users are attracted to it is the potential for high returns on investment. Whether they are individual investors or institutions, everyone wants a good return on their investment. Initially, the concept of yield farming emerged with the introduction of LP tokens. These tokens were given to users as a reward for providing liquidity to Automated Market Maker (AMM) platforms and borrowing/lending platforms. Eventually, protocols started offering interest to users for their deposits. This marked the first phase of yield farming, where users would contribute funds to a pool and receive returns.

Initially, the yield was very high using this method. However, it started decreasing as the pools became more stable. Nevertheless, users still craved high yields.

In 2021, the introduction of the Yearn vault changed the landscape of yield farming for users. Instead of having to research high-yield pools, users can now easily maximize their returns by depositing their assets into the Yearn vault. All of these developments were happening within a single chain.

## Problem
Imagine the user holds USDC on Gnosis (because he loves Gnosis), but then he discovers a yearn vault on the optimism network that offers a 200% APY on USDC. In order to access this 200% yield, the user would need to leave the Gnosis chain, bridge their USDC to optimism, and deposit it into yearn.

For users, this process can be quite cumbersome and risky. Additionally, Gnosis stands to lose these users.

### Is there a way where users can be on Gnosis and enjoy its fast transactions and also enjoy the high yield provided by other chains?
→ Yes

## Solution
To address this problem, we have introduced a crondex vault. The crondex vault functions as a cross-chain vault, allowing assets to be transferred from one chain to another in order to generate yield. The generated yield is then returned back to the source chain.

### How does it work?

To enable this functionality, we utilize the connext xcall and xtokens. When a user deposits XUSDC to the crondex vault on the Gnosis chain, it is sent to our receiver contract on the optimism chain. Upon receiving the XUSDC, the receiver contract deposits it into the reaper vault to maximize the yield on the optimism chain. Currently, we have integrated the reaper vault, but this may vary in the future. When a user wishes to withdraw their funds, they can convert their cvUSDC token back to USDC on the Gnosis chain and claim their USDC along with the generated yield.
![image](https://github.com/pokhrelanmol/crondex/assets/75737628/66cb0e98-725b-45a4-be0c-e6b54b8fed6d)

## Setup
This project is still in the development phase and it is only accessible on goerli testnet with TEST tokens.But we have a fork test from arbitrum to optimism which you can run using test command

- ```git clone https://github.com/crondexHackaton/crondex```
- ```cd crondex```
- ```forge install```
- ```npm i```
- ```forge test```


