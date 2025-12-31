
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockFractionalToken {
    uint256 public totalSupply = 1000;
    mapping(address => uint256) public balances;

    constructor() {
        balances[msg.sender] = 400; // 40%
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}
