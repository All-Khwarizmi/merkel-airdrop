// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TacoToken is ERC20 {
    constructor() ERC20("TacoToken", "TACO") {
        _mint(msg.sender, 1000 * 10 ** 18);
    }
}
