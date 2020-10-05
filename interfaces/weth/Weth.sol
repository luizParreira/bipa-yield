//SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

interface IWeth {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}
