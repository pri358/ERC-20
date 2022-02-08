const main = async () => {
    // compile the contract
    // hre: hardhat runtime environment, provided by hardhat everytime we compile
    const nftContractFactory = await hre.ethers.getContractFactory('MyErc20');
    // deploy a local blockchain just for this contract that gets deleted at the end of the script
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    console.log("Contract deployed to: ", nftContract.address);
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } 
    catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();