// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

interface IVault {
    function deposit(uint256 _amount) external;

    function depositAll() external;

    function withdraw(uint256 _amount) external;

    function withdrawAll() external;
}

// NOTE: Basically an alias for Vaults
interface yERC20 {
    function deposit(uint256 _amount) external;

    function withdraw(uint256 _amount) external;

    function getPricePerFullShare() external view returns (uint256);
}
