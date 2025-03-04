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
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    using SafeERC20 for IERC20;

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    bytes32 private constant MESSAGE_TYPEHASH = keccak256(bytes("AirdropClaim(address account,uint256 amount)"));

    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    address[] public claimers;
    mapping(address => bool) private hasClaim;

    event Claim(address claimer, uint256 amount);

    constructor(IERC20 airdropToken, bytes32 merkleRoot) EIP712("MerkleAirdrop", "1") {
        i_airdropToken = airdropToken;
        i_merkleRoot = merkleRoot;
    }

    function claim(address account, uint256 amount, bytes32[] calldata proof, uint8 v, bytes32 r, bytes32 s) public {
        if (hasClaim[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));

        if (!MerkleProof.verify(proof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        hasClaim[account] = true;

        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim(account, amount))));
    }

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address actualSigner,) = ECDSA.tryRecover(digest, v, r, s);

        return actualSigner == account;
    }

    function getMerkleRoot() public view returns (bytes32) {
        return i_merkleRoot;
    }

    function getClaimerHasClaimed(address claimer) public view returns (bool) {
        return hasClaim[claimer];
    }
}
