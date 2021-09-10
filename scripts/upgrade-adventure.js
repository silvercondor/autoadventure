const {ethers, upgrades}=require('hardhat')
const {initImpl}=require('./init-impl')
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

  const implAddress = await upgrades.erc1967.getImplementationAddress(autoAdventure.address);
  
  console.log(`implementation address: ${implAddress}`)
  console.log(`proxy address: ${autoAdventure.address}`)

  //uups proxy vulnerability fix
  //More info: https://forum.openzeppelin.com/t/security-advisory-initialize-uups-implementation-contracts/15301
  await initImpl(implAddress)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
