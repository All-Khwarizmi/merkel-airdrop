// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract InteractScript is Script {
    bytes32 immutable i_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 constant AMOUNT_TO_AIRDROP = 4 * 25 * 1e18;

    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    bytes32 PROOF_ONE = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF_TWO = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;

    bytes32[] proof = [PROOF_ONE, PROOF_TWO];

    function run() public {
        address mostRecentDeployedContract = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);

        claimAirdrop();
    }

    function claimAirdrop(address airdropContractAddress) public {
        vm.startBroadcast();
        MerkleAirdrop(airdropContractAddress).claim(CLAIMING_ADDRESS, AMOUNT_TO_AIRDROP, proof);
        vm.stopBroadcast();
    }
}
