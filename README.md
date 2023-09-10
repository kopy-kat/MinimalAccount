<img align="right" width="150" height="150" top="100" src="./assets/blueprint.png">

# MinimalAccount

The most gas optimized ERC-4337 account - written in Huff.

> **Note**
>
> These contracts are **unaudited** and are not recommended for use in production.
>
> The main usage of these contracts is to benchmark other ERC-4337 accounts against the lowest possible gas cost for an account.

## Gas calculations (as of Sep 10, 2023)

|                  | Creation | Native transfer | ERC20 transfer | Total  |
| ---------------- | -------- | --------------- | -------------- | ------ |
| MinimalAccount   | 243454   | 94023           | 82760          | 420237 |
| SimpleAccount    | 410061   | 97690           | 86754          | 594505 |
| Biconomy         | 296892   | 100780          | 89577          | 487249 |
| Etherspot        | 305769   | 100091          | 89172          | 495032 |
| Kernel v2.0      | 366662   | 106800          | 95877          | 569339 |
| Kernel v2.1      | 291413   | 103240          | 92289          | 486942 |
| Kernel v2.1-lite | 256965   | 97331           | 86121          | 440417 |

Calculations are based on ZeroDev's [AA Benchmark](https://github.com/zerodevapp/aa-benchmark)

## Using this repo

1. Clone this repo

```
git clone https://github.com/kopy-kat/MinimalAccount.git
cd MinimalAccount
```

2. Install dependencies

Once you've cloned and entered into your repository, you need to install the necessary dependencies. In order to do so, simply run:

```shell
forge install
```

3. Build & Test

To build and test your contracts, you can run:

```shell
forge build
forge test
```

For more information on how to use Foundry, check out the [Foundry Github Repository](https://github.com/foundry-rs/foundry/tree/master/forge) and the [foundry-huff library repository](https://github.com/huff-language/foundry-huff).

## Todo

- [ ] Dynamically splice owner account into bytecode
- [ ] Deploy as minimal clone

## License

[The Unlicense](https://github.com/huff-language/huff-project-template/blob/master/LICENSE)

## Acknowledgements

- [ERC4337's SimpleAccount](https://github.com/eth-infinitism/account-abstraction/blob/develop/contracts/samples/SimpleAccount.sol)
- [Huffmate](https://github.com/huff-language/huffmate)
- [Huff](https://huff.sh)

## Disclaimer

_These smart contracts are being provided as is. No guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of the user interface or the smart contracts. They have not been audited and as such there can be no assurance they will work as intended, and users may experience delays, failures, errors, omissions, loss of transmitted information or loss of funds. The creators are not liable for any of the foregoing. Users should proceed with caution and use at their own risk._
