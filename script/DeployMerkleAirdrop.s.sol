// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {TacoToken} from "../src/TacoToken.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 immutable i_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 constant AMOUNT_TO_AIRDROP = 4 * 25 * 1e18;

    function run() public returns (MerkleAirdrop airdrop, TacoToken tacoToken) {
        vm.startBroadcast();
        tacoToken = new TacoToken();
        airdrop = new MerkleAirdrop(IERC20(address(tacoToken)), i_merkleRoot);

        tacoToken.mint(address(airdrop), AMOUNT_TO_AIRDROP);
        
        vm.stopBroadcast();
    }
}
