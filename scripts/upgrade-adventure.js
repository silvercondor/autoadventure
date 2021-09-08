const {ethers, upgrades}=require('hardhat')
// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const contractAddr="0xf3630d28E451C63fCFD5eCdEF6fD7c87379911a0"
  const AutoAdventure = await ethers.getContractFactory("AutoAdventure")
  const autoAdventure = await upgrades.upgradeProxy(contractAddr, AutoAdventure)

  await autoAdventure.deployed();
  console.log(`contract deployed at address ${autoAdventure.address}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
