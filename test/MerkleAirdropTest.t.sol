// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {TacoToken} from "../src/TacoToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReadTreeScript} from "../script/ReadTree.s.sol";

contract MerkleAirdropTest is Test {
    TacoToken tacoToken;
    MerkleAirdrop airdrop;
    bytes32 merkleRoot;

    function setUp() public {
        tacoToken = new TacoToken();
        merkleRoot = new ReadTreeScript().getMerkleRoot();
        airdrop = new MerkleAirdrop(IERC20(address(tacoToken)), merkleRoot);
    }

    function testMerkleRootIsCorrect() public {
        assertEq(airdrop.getMerkleRoot(), merkleRoot);
    }

    function testTacoTokenIsCorrect() public {
        assertEq(tacoToken.balanceOf(address(airdrop)), 0);
    }
}
