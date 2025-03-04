# TacoAirdrop

An airdrop contract for the TacoToken that uses merkle proofs to verify the airdrop recipients.

> [!NOTE]
> Merkle Trees are a cryptographic data structure that allows you to encrypt and store blockchain data more securely and efficiently.
>
> Merkle proofs are a way to prove that a particular element is part of a set without revealing the entire set. In this case, the set is the list of airdrop recipients and the element is the recipient's address.

> [!IMPORTANT]  
> Why use a merkle tree for airdrops?

Let's say that we don't use merkle trees and you want to airdrop 100 Tacos (tokens) to 10 people. Each person will have to call the claim function. We then would have to iterate through the list of 10 addresses and verify that the address is part of the list.

```solidity

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BadAirdrop {
address[] public allowedAddresses;
uint256 public totalAmount;
uint256 public token;

function claim(address _address) public {
    for (uint256 i = 0; i < allowedAddresses.length; i++) {
        if (allowedAddresses[i] == _address) {
            IERC20(token).transfer(_address, totalAmount / allowedAddresses.length);
        }
    }

}

}
```

This is a very inefficient way to do it because if we have a very large list of addresses, we would have to iterate through the list of addresses for each claim and possibly run into DOS vulnerabilities.

> [!TIP]
> DOS or Denial of Service is when a machine or network resource becomes unavailable to its intended users by temporarily or indefinitely.
> In this case due to the large amount of address the function would run out of gas.
