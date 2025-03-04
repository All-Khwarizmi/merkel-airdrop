// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {TacoToken} from "../src/TacoToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReadTreeScript} from "../script/ReadTree.s.sol";
import {DeployScript} from "../script/Deploy.s.sol";

contract MerkleAirdropTest is Test {
    TacoToken tacoToken;
    MerkleAirdrop airdrop;
    bytes32 merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    bytes32[] proof;
    uint256 constant amount = 25 * 1e18;

    address user;
    uint256 privateKey;

    function setUp() public {
        (user, privateKey) = makeAddrAndKey("user");

        (airdrop, tacoToken) = new DeployScript().run();

        proof = new bytes32[](2);

        proof[0] = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
        proof[1] = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    }

    function testMerkleRootIsCorrect() public {
        assertEq(airdrop.getMerkleRoot(), merkleRoot);
    }

    function testClaimShouldRevertIfProofIsInvalid() public {
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__InvalidProof.selector);

        vm.prank(user);
        airdrop.claim(100, new bytes32[](0));
    }

    function testClaimShouldSetHaClaimFlagToTrue() public {
        vm.prank(user);
        airdrop.claim(amount, proof);
        assert(airdrop.getClaimerHasClaimed(user));
    }

    function testClaimShouldRevertIfClaimerHasAlreadyClaimed() public {
        vm.prank(user);
        airdrop.claim(amount, proof);
        
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__AlreadyClaimed.selector);

        vm.prank(user);
        airdrop.claim(100, new bytes32[](0));
    }
}
