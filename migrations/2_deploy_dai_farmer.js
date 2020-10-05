const DaiFarmer = artifacts.require("DaiFarmer");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(DaiFarmer, {from: accounts[0]});
};
