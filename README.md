<img align="right" width="150" height="150" top="100" src="./assets/blueprint.png">

# MinimalAccount

An ERC-4337 account written in Huff, to see how cheap one can get.

A smart account is a wallet that is a contract instead of a private key. Huff is a low-level language where you write the EVM opcodes yourself.

It has not been audited, so don't put funds in it. I use it as a baseline: when other accounts are benchmarked, it shows how far they are from the lowest cost I could get to.

## Features

- Only takes calls from the EntryPoint (v0.6)
- Validates a user operation with one ECDSA signature from the owner and rejects malleable signatures
- The owner's address is written into the bytecode by the factory, so the account has no storage and the owner can't change
- Executes one call per user operation, from packed calldata (target, value, data) with no function selector
- Pays the EntryPoint what it asks for during validation
- Receives ETH
- The factory deploys with CREATE2 and can return the address before deployment
- The deployed account is 261 bytes

## Gas calculations (as of Sep 21, 2023)

|                  | Creation | Native transfer | ERC20 transfer | Total  |
| ---------------- | -------- | --------------- | -------------- | ------ |
| MinimalAccount   | 222902   | 93254           | 81883          | 398039 |
| SimpleAccount    | 410061   | 97690           | 86754          | 594505 |
| Biconomy         | 296892   | 100780          | 89577          | 487249 |
| Etherspot        | 305769   | 100091          | 89172          | 495032 |
| Kernel v2.0      | 366662   | 106800          | 95877          | 569339 |
| Kernel v2.1      | 291413   | 103240          | 92289          | 486942 |
| Kernel v2.1-lite | 256965   | 97331           | 86121          | 440417 |

Gas difference between MinimalAccount and cheapest account in each category:

|               | Creation | Native transfer | ERC20 transfer | Total |
| ------------- | -------- | --------------- | -------------- | ----- |
| MA cheaper by | 34063    | 4077            | 4238           | 42378 |

Calculations are based on ZeroDev's [AA Benchmark](https://github.com/zerodevapp/aa-benchmark)

## Using this repo

```shell
forge install
forge build
forge test
```

It needs [Foundry](https://github.com/foundry-rs/foundry) and [foundry-huff](https://github.com/huff-language/foundry-huff).

## License

[The Unlicense](https://github.com/huff-language/huff-project-template/blob/master/LICENSE)

## Acknowledgements

- [ERC4337's SimpleAccount](https://github.com/eth-infinitism/account-abstraction/blob/develop/contracts/samples/SimpleAccount.sol)
- [Huffmate](https://github.com/huff-language/huffmate)
- [Huff](https://huff.sh)

## Disclaimer

_These smart contracts are being provided as is. No guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of the user interface or the smart contracts. They have not been audited and as such there can be no assurance they will work as intended, and users may experience delays, failures, errors, omissions, loss of transmitted information or loss of funds. The creators are not liable for any of the foregoing. Users should proceed with caution and use at their own risk._
