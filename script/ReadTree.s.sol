// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";

contract ReadTreeScript is Script {
    struct Tree {
        string format;
        string[] leafEncoding;
        bytes32[] tree;
        bytes32[] values;
    }

    function run() public {
        getMerkleRoot();
    }

    function getMerkleRoot() public returns (bytes32 root) {
        string memory json = vm.readFile("tree.json");
        bytes memory data = vm.parseJson(json);
        Tree memory tree = abi.decode(data, (Tree));
        root = tree.tree[0];
    }
}
