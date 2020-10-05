const {BN, ether, balance} = require("openzeppelin-test-helpers");
const {expect, assert} = require("chai");
const DaiFarmer = artifacts.require("DaiFarmer");
// import web3 from "web3";

const asyncForEach = async (array, callback) => {
  for (let index = 0; index < array.length; index++) {
    await callback(array[index], index, array);
  }
};

contract("DaiFarmer", async ([owner, other]) => {
  it("deploys and starts at balance 0", async () => {
    let instance = await DaiFarmer.new({from: owner});

    let meta = instance;

    let balance = await meta.balanceEth.call();
    const ethBalance = balance.toNumber();

    balance = await meta.balanceWeth.call();
    const wethBalance = balance.toNumber();

    balance = await meta.balanceDai.call();
    const daiBalance = balance.toNumber();

    balance = await meta.balanceYCrv.call();
    const yCrvBalance = balance.toNumber();

    balance = await meta.balanceYVault.call();
    const yVaultBalance = balance.toNumber();

    assert.equal(ethBalance, 0, "Eth Balance after not 90");
    assert.equal(wethBalance, 0, "WEth Balance after not 0");
    assert.equal(daiBalance, 0, "DAI Balance after not 0");
    assert.equal(yCrvBalance, 0, "yCRV Balance after not 0");
    assert.equal(yVaultBalance, 0, "yVault Balance after not 0");
  });

  it("should deposit ETH into curve and yearn's pools", async () => {
    const amount = ether("10");

    let instance = await DaiFarmer.new({from: owner});

    let meta = instance;
    let balance = await meta.balanceEth.call();
    const ethBalanceBefore = balance.toString();

    await meta.earn({from: owner, value: amount});

    balance = await meta.balanceEth.call();
    const ethBalanceAfter = balance.toString();

    balance = await meta.balanceWeth.call();
    const wethBalance = balance.toString();

    balance = await meta.balanceDai.call();
    const daiBalance = balance.toString();

    balance = await meta.balanceY.call();
    const idaiBalance = balance.toString();

    balance = await meta.balanceYCrv.call();
    const yCrvBalance = balance.toString();

    balance = await meta.balanceYVault.call();
    const yVaultBalance = balance.toString();

    assert.equal(ethBalanceBefore, "0", "Eth Balance before not 100");
    assert.equal(ethBalanceAfter, "0", "Eth Balance after not 90");
    assert.equal(wethBalance, "0", "WEth Balance after not 0");
    assert.equal(daiBalance, "0", "DAI Balance after not 0");
    assert.equal(idaiBalance, "0", "iDAI Balance after not 0");
    assert.equal(yCrvBalance, "0", "yCRV Balance after not 0");
    expect(new BN(yVaultBalance) > 0, "We are left with yVault token");
  });

  it("should withdraw all of yearn's pool token into ETH", async () => {
    const amount = ether("1");

    let instance = await DaiFarmer.new({from: owner});

    let meta = instance;
    await meta.earn({from: owner, value: amount});

    let balance = await meta.ownerBalance.call();
    const ownerBalanceBefore = balance.toString();

    await meta.withdrawAll({from: owner});

    balance = await meta.balanceWeth.call();
    const wethBalance = balance.toString();

    balance = await meta.balanceDai.call();
    const daiBalance = balance.toString();

    balance = await meta.balanceY.call();
    const idaiBalance = balance.toString();

    balance = await meta.balanceYCrv.call();
    const yCrvBalance = balance.toString();

    balance = await meta.balanceYVault.call();
    const yVaultBalance = balance.toString();

    balance = await meta.ownerBalance.call();
    const ownerBalanceAfter = balance.toString();

    balance = await meta.balanceYUsdc.call();
    const balanceYUsdc = balance.toString();

    balance = await meta.balanceYUsdt.call();
    const balanceYUsdt = balance.toString();

    balance = await meta.balanceYTusd.call();
    const balanceYTusd = balance.toString();

    balance = await meta.ownerBalanceWeth.call();
    const ownerBalanceWeth = balance.toString();

    assert.equal(wethBalance, "0", "WEth balance not 0");
    assert.equal(daiBalance, "0", "DAI balance not 0");
    assert.equal(idaiBalance, "0", "iDAI balance not 0");
    assert.equal(balanceYUsdc, "0", "yUSDC balance not 0");
    assert.equal(balanceYUsdt, "0", "yUSDT balance not 0");
    assert.equal(balanceYTusd, "0", "yTUSD balance not 0");
    assert.equal(ownerBalanceWeth, "0", "Owner WETH balance not 0");
    assert.equal(yCrvBalance, "0", "yCRV balance not 0");
    assert.equal(yVaultBalance, "0", "yVault balance not 0");
    expect(
      ownerBalanceAfter > ownerBalanceBefore,
      "After withdrawing, balance should be bigger"
    );
  });
});
