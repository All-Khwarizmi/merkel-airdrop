// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {TacoToken} from "../src/TacoToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdropTest is Test {
    TacoToken tacoToken;
    MerkleAirdrop airdrop;

    function setUp() public {
        tacoToken = new TacoToken();
        airdrop = new MerkleAirdrop(IERC20(address(tacoToken)), bytes32(0x0));
    }
}
