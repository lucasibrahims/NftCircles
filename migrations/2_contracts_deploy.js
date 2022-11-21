const Circles = artifacts.require("Circles");
module.exports = async function (deployer) {
  await deployer.deploy(Circles);
};
