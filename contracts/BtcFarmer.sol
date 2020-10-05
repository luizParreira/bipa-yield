//SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/ren/Ren.sol";
import "../interfaces/curve/Curve.sol";
import "../interfaces/yearn/Yearn.sol";

// Deposit
// 1. Handle BTC Deposit into renBTC
// 2. Once we have renBTC, we deposit it into curve's sBTC pool and get a crvBTC
// 3. Once we have the crvBTC token, we deposit it into yearn's crvBTC vault and get ycrvBTC

// Withdrawals
// 1. User chooses to withdraw his BTC
// 2. He chooses either directly to BTC or to one of the curve's pool assets
// 3. Contract sends his token

// contract BtcFarmer is Ownable {
//     IGatewayRegistry public registry;

//     address public constant renBTC = address(
//         0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D
//     );
//     address public constant curve = address(
//         0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714
//     );
//     address public constant crvBTC = address(
//         0x3740fb63ab7a09891d7c0d4299442A551D06F5fD
//     );
//     address public constant yVault = address(
//         0x7Ff566E1d69DEfF32a7b244aE7276b9f90e9D0f6
//     );

//     event Deposit(uint256 _amount);
//     event Withdrawal(bytes _to, uint256 _amount);

//     constructor(IGatewayRegistry _registry) public {
//         registry = _registry;
//     }

//     function deposit(
//         // Parameters from Darknodes
//         uint256 _amount,
//         bytes32 _nHash,
//         bytes calldata _sig
//     ) external onlyOwner {
//         bytes32 pHash = keccak256(abi.encode(_msg));
//         uint256 mintedAmount = registry.getGatewayBySymbol("BTC").mint(
//             pHash,
//             _amount,
//             _nHash,
//             _sig
//         );
//         emit Deposit(mintedAmount);
//     }

//     function earn() external onlyOwner {
//         uint256 _btcBalance = IERC20(renBTC).balanceOf(address(this));
//         if (_btcBalance > 0) {
//             IERC20(renBTC).safeApprove(curve, 0);
//             IERC20(renBTC).safeApprove(curve, renBTC);
//             ICurveFi(curve).add_liquidity([_btcBalance, 0, 0], 0);
//             uint256 _crvbtcBalance = IERC20(crvBTC).balanceOf(address(this));
//             if (_crvbtcBalance > 0) {
//                 IERC20(crvBTC).safeApprove(yearn, 0);
//                 IERC20(crvBTC).safeApprove(yearn, crvBTC);
//                 yVault(yVault).deposit(_crvbtcBalance);
//             }
//         }
//     }

//     function withdrawAll() external onlyOwner {
//         uint256 yearnTokenBalance = IERC20(yVault).balanceOf(address(this));
//         if (yearnTokenBalance > 0) {
//             withdraw(yearnTokenBalance);
//         }
//     }

//     // Calling withdraw and only withdrawing a given amount
//     function withdraw(uint256 _amount) external onlyOwner {
//         uint256 _yearnTokenBalance = IERC20(yVault).balanceOf(address(this));
//         if (_yearnTokenBalance >= _amount) {
//             yVault(yVault).withdraw(_amount);
//             Zap(curve).remove_liquidity_one_coin(_amount, renBTC, _amount);
//             uint256 _btcBalance = IERC20(renBTC).balanceOf(address(this));

//             if (_btcBalance > 0) {
//                 uint256 burnedAmount = registry.getGatewayBySymbol("BTC").burn(
//                     _to,
//                     _amount
//                 );
//                 emit Withdrawal(_to, burnedAmount);
//             }
//         }
//     }

//     function balance() public view onlyOwner returns (uint256) {
//         return registry.getTokenBySymbol("BTC").balanceOf(address(this));
//     }
// }
