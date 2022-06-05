const Migrations = artifacts.require("Migrations");
const Termination = artifacts.require("Termination");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Termination);
};
