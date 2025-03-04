// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MerkleAirdrop is Ownable {
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    using SafeERC20 for IERC20;

    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    address[] public claimers;
    mapping(address => bool) private hasClaim;

    event Claim(address claimer, uint256 amount);

    constructor(IERC20 airdropToken, bytes32 merkleRoot) Ownable() {
        i_airdropToken = airdropToken;
        i_merkleRoot = merkleRoot;
    }

    function claim(uint256 amount, bytes32[] calldata proof) public {
        if (hasClaim[msg.sender]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, amount))));

        if (!MerkleProof.verify(proof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        hasClaim[msg.sender] = true;

        emit Claim(msg.sender, amount);
        i_airdropToken.safeTransfer(msg.sender, amount);
    }

    function setClaimer(address claimer) public onlyOwner {
        claimers.push(claimer);
    }

    function setHasClaimed(address[] calldata _claimers) public onlyOwner {
        for (uint256 i = 0; i < _claimers.length; i++) {
            hasClaim[claimers[i]] = true;
        }
    }

    function getMerkleRoot() public view returns (bytes32) {
        return i_merkleRoot;
    }

    function getClaimerHasClaimed(address claimer) public view returns (bool) {
        return hasClaim[claimer];
    }
}
