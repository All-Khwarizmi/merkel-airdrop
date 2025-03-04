// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract InteractScript is Script {
    uint256 CLAIMING_AMOUNT = 25000000000000000000;
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    bytes32 PROOF_ONE = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF_TWO = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;

    bytes32[] proof = [PROOF_ONE, PROOF_TWO];

    uint256 privateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    bytes private SIGNATURE =
        hex"12e145324b60cd4d302bfad59f72946d45ffad8b9fd608e672fd7f02029de7c438cfa0b8251ea803f361522da811406d441df04ee99c3dc7d65f8550e12be2ca1c";

    error ClaimAirdropScript__InvalidSignatureLength();

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }

    function claimAirdrop(address airdropContractAddress) public {
        vm.startBroadcast();
        // (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);

        // (, uint256 privateKey) = makeAddrAndKey("user");
        console.log("Get message hash");

        bytes32 messageHash = MerkleAirdrop(airdropContractAddress).getMessageHash(CLAIMING_ADDRESS, CLAIMING_AMOUNT);
        console.log("Message hash obtained");
        console.log("Signature...");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash); // Sign the messageHash with the private key of the user

        console.log("Claiming Airdrop");
        MerkleAirdrop(airdropContractAddress).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r, s);
        vm.stopBroadcast();
        console.log("Claimed Airdrop");
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert ClaimAirdropScript__InvalidSignatureLength();
        }

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
