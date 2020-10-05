//SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/ren/Ren.sol";
import "../interfaces/curve/Curve.sol";
import "../interfaces/curve/Mintr.sol";
import "../interfaces/yearn/Yearn.sol";
import "../interfaces/uniswap/Uniswap.sol";
import "../interfaces/weth/Weth.sol";

contract DaiFarmer is Ownable {
    address public constant uniswap = address(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );
    address public constant weth = address(
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    );

    address public constant curve = address(
        0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51
    );
    address public constant ycrv = address(
        0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8
    );

    address public constant yVault = address(
        0x5dbcF33D8c2E976c6b560249878e6F1491Bca25c
    );

    address public constant dai = address(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    address public constant y = address(
        0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01
    );

    address public constant yusdc = address(
        0xd6aD7a6750A7593E092a9B218d66C0A814a3436e
    );

    address public constant yusdt = address(
        0x83f798e925BcD4017Eb265844FDDAbb448f1707D
    );

    address public constant ytusd = address(
        0x73a052500105205d34Daf004eAb301916DA8190f
    );

    receive() external payable {}

    function earn() external payable onlyOwner {
        IWeth(weth).deposit{value: msg.value}();

        require(
            msg.value > 0,
            "We do not have WETH in order to swap in Uniswap"
        );

        address[] memory path = new address[](2);
        (path[0], path[1]) = (weth, dai);

        IERC20(weth).approve(uniswap, 0);
        IERC20(weth).approve(uniswap, msg.value);
        uint256 _tokenAmount = IUniswap(uniswap).swapExactTokensForTokens(
            msg.value,
            0,
            path,
            address(this),
            block.timestamp
        )[1];

        require(_tokenAmount > 0, "Uniswap swap failed, we do not have DAI");

        IERC20(dai).approve(y, 0);
        IERC20(dai).approve(y, _tokenAmount);
        yERC20(y).deposit(_tokenAmount);

        uint256 _y = IERC20(y).balanceOf(address(this));
        require(_y > 0, "iDai balance is 0");

        IERC20(y).approve(curve, 0);
        IERC20(y).approve(curve, _y);
        ICurveFi(curve).add_liquidity([_y, 0, 0, 0], 0);

        uint256 _ycrvBalance = IERC20(ycrv).balanceOf(address(this));

        require(_ycrvBalance > 0, "Failed to add liquidity to Curve");
        IERC20(ycrv).approve(yVault, 0);
        IERC20(ycrv).approve(yVault, _ycrvBalance);
        IVault(yVault).deposit(_ycrvBalance);
    }

    function withdrawAll() external onlyOwner {
        uint256 _yearnTokenBalance = IERC20(yVault).balanceOf(address(this));

        require(_yearnTokenBalance > 0, "We don't have any yearn vault tokens");

        withdraw(_yearnTokenBalance);
    }

    // Calling withdraw and only withdrawing a given amount
    function withdraw(uint256 _amount) public onlyOwner {
        uint256 _yearnTokenBalance = IERC20(yVault).balanceOf(address(this));

        require(
            _yearnTokenBalance >= _amount,
            "Insuficient balance, we dont have that many yVault tokens"
        );

        IVault(yVault).withdraw(_amount);

        uint256 _ycrvBalance = IERC20(ycrv).balanceOf(address(this));

        require(_ycrvBalance > 0, "No yCRV balance");

        IERC20(ycrv).approve(curve, 0);
        IERC20(ycrv).approve(curve, _ycrvBalance);
        ICurveFi(curve).remove_liquidity(_ycrvBalance, [uint256(0), 0, 0, 0]);

        uint256 _yusdc = IERC20(yusdc).balanceOf(address(this));
        uint256 _yusdt = IERC20(yusdt).balanceOf(address(this));
        uint256 _ytusd = IERC20(ytusd).balanceOf(address(this));

        if (_yusdc > 0) {
            IERC20(yusdc).approve(curve, 0);
            IERC20(yusdc).approve(curve, _yusdc);
            ICurveFi(curve).exchange(1, 0, _yusdc, 0);
        }
        if (_yusdt > 0) {
            IERC20(yusdt).approve(curve, 0);
            IERC20(yusdt).approve(curve, _yusdt);
            ICurveFi(curve).exchange(2, 0, _yusdt, 0);
        }
        if (_ytusd > 0) {
            IERC20(ytusd).approve(curve, 0);
            IERC20(ytusd).approve(curve, _ytusd);
            ICurveFi(curve).exchange(3, 0, _ytusd, 0);
        }

        yERC20(y).withdraw(IERC20(y).balanceOf(address(this)));

        uint256 _daiBalance = IERC20(dai).balanceOf(address(this));

        require(_daiBalance > 0, "DAI balance is 0");

        address[] memory path = new address[](2);
        (path[0], path[1]) = (dai, weth);

        IERC20(dai).approve(uniswap, 0);
        IERC20(dai).approve(uniswap, _daiBalance);

        uint256 _wethAmount = IUniswap(uniswap).swapExactTokensForTokens(
            _daiBalance,
            0,
            path,
            address(this),
            block.timestamp
        )[1];

        require(_wethAmount > 0, "No WETH balance");
        IWeth(weth).withdraw(_wethAmount);
    }

    function ownerBalance() public view returns (uint256) {
        return owner().balance;
    }

    function ownerBalanceWeth() public view returns (uint256) {
        return IERC20(weth).balanceOf(owner());
    }

    function balanceDai() public view returns (uint256) {
        return IERC20(dai).balanceOf(address(this));
    }

    function balanceEth() public view returns (uint256) {
        return address(this).balance;
    }

    function balanceY() public view returns (uint256) {
        return IERC20(y).balanceOf(address(this));
    }

    function balanceYUsdc() public view returns (uint256) {
        return IERC20(yusdc).balanceOf(address(this));
    }

    function balanceYTusd() public view returns (uint256) {
        return IERC20(ytusd).balanceOf(address(this));
    }

    function balanceYUsdt() public view returns (uint256) {
        return IERC20(yusdt).balanceOf(address(this));
    }

    function balanceWeth() public view returns (uint256) {
        return IERC20(weth).balanceOf(address(this));
    }

    function balanceYVault() public view returns (uint256) {
        return IERC20(yVault).balanceOf(address(this));
    }

    function balanceYCrv() public view returns (uint256) {
        return IERC20(ycrv).balanceOf(address(this));
    }
}
