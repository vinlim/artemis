# Artemis Collective

Art investment has been a desirable asset class, outperforming the S&P500 historically. However, it is only accessible
to the wealthy and connected. Artemis Collective aims to democratize art investment with Tokenized Fractional RWA on the
Aptos blockchain.

Think Robinhood for blue-chip Fine Art Investment

# How it works

- Platform/operator can tokenize a Physical Fine Art as an asset with `_::artemis_one::create_asset`
- The module will create a `Digital Asset` with a corresponding `Fungible Asset` with the determined total supply
- Each FA token represent a share of ownership in the corresponding tokenized asset
- Investors can purchase any amount of token with `_::artemis_one::purchase_fractional_ownership`
- The FA tokens can be freely traded in the secondary market
- In the event of liquidation, the proceed will be distributed to the FA token holder in proportion of their holdings
  against the total supply for the specific asset, and the total FA token supply of the specific asset will be burned
  with `_::artemis_one::burn`
- Holder can choose to acquire the total supply and claim custody of the tokenized asset with `_::artemis_one::claim_asset`.The tokenized asset can be use
  to redeem the physical asset when deisired. The total FA token supply will also be burned.

# Aptos Blockchain

Leveraging the Aptos blockchain, Artemis Collective provides a secure, efficient, and scalable platform for art asset
tokenization. Aptos's resource-oriented architecture facilitates structural and efficient tokenization and
fractionalization without the need for deploying separate smart contracts for different resources like the ERC-7631.

We make use of the native Digital Asset and Fungible Asset standards that offer a unified framework for creating,
managing, and transferring digital representations of real-world assets. These standards ensure compatibility and
interoperability across the ecosystem, while also simplify the process of tokenizing physical art assets and its
fractional representation. This approach greatly reduces complexity and significantly mitigates security risks
associated with deploying multiple
smart contracts, and the needs for these smart contracts to communicate.

Aptos blockchain's high throughput and optimized performance effectively also negate the gas fee issues that plague
other
blockchain platforms.
