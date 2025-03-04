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
    bytes32[] proof;
    uint256 constant amount = 1000000000000000000;

    address user = makeAddr("0x6666666666666666666666666666666666666666");

    function setUp() public {
        tacoToken = new TacoToken();
        merkleRoot = new ReadTreeScript().getMerkleRoot();
        airdrop = new MerkleAirdrop(IERC20(address(tacoToken)), merkleRoot);

        proof = new bytes32[](3);

        proof[0] = 0x76b785cc4507bdc43cee4e101cebf2593dea5be9a67ec8d73618c7408ea11a31;
        proof[1] = 0x36a4737d5cf925b6a812d376c062ec9d663d9f18284285d3a3ffc62ab747ebbb;
        proof[2] = 0x374e1c14ad60f4a285f936df56a187dd5803d7cfe382d50103a9428d791539a8;
    }

    function testMerkleRootIsCorrect() public {
        assertEq(airdrop.getMerkleRoot(), merkleRoot);
    }

    function testTacoTokenIsCorrect() public {
        assertEq(tacoToken.balanceOf(address(airdrop)), 0);
    }

    modifier setClaimer() {
        airdrop.setClaimer(user);
        address[] memory claimers = new address[](1);
        claimers[0] = user;
        airdrop.setHasClaimed(claimers);

        assert(airdrop.getClaimerHasClaimed(user));
        _;
    }

    function testClaimShouldRevertIfClaimerHasAlreadyClaimed() public setClaimer {
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__AlreadyClaimed.selector);

        vm.prank(user);
        airdrop.claim(100, new bytes32[](0));
    }

    function testClaimShouldRevertIfProofIsInvalid() public {
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__InvalidProof.selector);

        vm.prank(user);
        airdrop.claim(100, new bytes32[](0));
    }

    function testClaimShouldSetHaClaimFlagToTrue() public {
        console.log("user", user);
        vm.prank(user);
        airdrop.claim(1000000000000000000, proof);
        assert(airdrop.getClaimerHasClaimed(user));
    }
}
