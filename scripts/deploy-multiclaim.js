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
  const MultiClaimer = await ethers.getContractFactory("MultiClaimer");
  const multiClaimer = await upgrades.deployProxy(MultiClaimer, {kind:'uups'})

  await multiClaimer.deployed();
  const implAddress = await upgrades.erc1967.getImplementationAddress(multiClaimer.address);
  
  console.log(`implementation address: ${implAddress}`)
  console.log(`proxy address: ${multiClaimer.address}`)

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
