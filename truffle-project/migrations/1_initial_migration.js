const Migrations = artifacts.require("Migrations");
const Termination1 = artifacts.require("Termination1");
const Termination2 = artifacts.require("Termination2");
const Termination3 = artifacts.require("Termination3");
const Termination4 = artifacts.require("Termination4");
const Termination5 = artifacts.require("Termination5");
const Termination6 = artifacts.require("Termination6");
const Termination7 = artifacts.require("Termination7");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Termination1);
  deployer.deploy(Termination2);
  deployer.deploy(Termination3);
  deployer.deploy(Termination4);
  deployer.deploy(Termination5);
  deployer.deploy(Termination6);
  deployer.deploy(Termination7);
};
