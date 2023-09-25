const ethers = require("ethers")
const {abi,bytecode} = require("../artifacts/contracts/NFT_Minter.sol/Minter.json")
//Add other imports here


const private1 = ""
const private2 = ""

//Probably want to use Polygon Mumbai
const RPC = ""
const provider = new ethers.providers.JsonRpcProvider(RPC)

const wallet1 = new ethers.Wallet(private1,RPC)
const wallet2 = new ethers.Wallet(private2,RPC)

const factory = new ethers.ContractFactory(abi,bytecode,wallet1)

async function start(){

    console.log("Deploying to chain")

    const contract = await factory.deploy(
        "Name","Symbol",wallet1.address
    )

    await contract.deployed()

    console.log(`Contract deployed at: ${contract.address}`)

    //Add other actions here
}