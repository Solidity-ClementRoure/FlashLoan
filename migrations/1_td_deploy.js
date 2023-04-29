const MyERC721 = artifacts.require("MyERC721");
const BouncerProxy = artifacts.require("BouncerProxy");
const Minter = artifacts.require("Minter");

module.exports = (deployer, network, accounts) => {
    deployer.then(async () => {

		// await deployer.deploy(MyERC721);
		// await deployer.deploy(BouncerProxy);

		await deployer.deploy(Minter, "0xd395E0B5853d308cD3b3DAaf7E09BAD308AC9635");
    });
};