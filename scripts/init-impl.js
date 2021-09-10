const {ethers} = require('hardhat')

async function initImpl(implAddress){
    console.log(`Initializing contract ${implAddress}`)

    const fnName='initialize'
    const iface = new ethers.utils.Interface([`function ${fnName}()`])
    const formattedIface=iface.format(ethers.utils.FormatTypes.json)

    const implContract = new ethers.Contract(implAddress, formattedIface, ethers.provider.getSigner())

    //call initialize on impl contract
    const initTx = await implContract[fnName]()
    console.log(`Sending transaction ${initTx.hash}`)
    await initTx.wait()
    console.log("Successfully initialized implementaiton contract")
}
module.exports = {initImpl}