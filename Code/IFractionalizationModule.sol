// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFractionalizationModule {
    function balanceOf(address account, uint256 id) external view returns (uint256);
}