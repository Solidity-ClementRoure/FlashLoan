require('dotenv').config()

const Minter = artifacts.require("Minter");
const MyERC721 = artifacts.require("MyERC721");
const BouncerProxy = artifacts.require("BouncerProxy");

const Evaluator = artifacts.require("Evaluator");
const TDErc20 = artifacts.require("ERC20TD.sol");

contract("Minter", async (accounts) => {

    const myWallet = "0x7bBfecDCF7d0E7e5aA5fffA4593c26571824CB87";
    const myERC721Address = "0xd395E0B5853d308cD3b3DAaf7E09BAD308AC9635"

    const aBytes32 = '0x00000000596f75206e65656420746f207369676e207468697320737472696e67'

    it("Should Sign", async()=>{

        const bouncerProxy = await BouncerProxy.new();

        // // Deploy test Evaluator
        const tdToken = await TDErc20.new("TD-Sign","TD-Sign",web3.utils.toBN("42000000000000000000000000000"));
        const evaluator = await Evaluator.new(
            tdToken.address, 
            bouncerProxy.address,
        );

        // // my contracts        
        const minter = await Minter.new(myERC721Address);

        // // init evaluator
        await tdToken.setTeacher(evaluator.address, true);
        // https://web3js.readthedocs.io/en/v1.2.11/web3-eth-contract.html?highlight=transactionHash#id36
        const tx = await evaluator.submitExercice(minter.address)
        // .on('transactionHash', async function(hash){ // wait for transaction to be minted

            // Exo_1
            // await evaluator.ex1_testERC721(
            // {
            //     from: myWallet
            // });

            // Exo_2
            const signature = web3.eth.accounts.sign(aBytes32, process.env.METAMASK_PRIVATE_KEY).signature
            console.log("Signature: " + signature)

            // await evaluator.ex2_generateASignature(
            // signature,
            // {
            //     from: myWallet
            // }
            // );

            // Exo_3
            // await evaluator.ex3_extractAddressFromSignature(
            //     {
            //     from: myWallet
            //     }
            // );

            // Exo_4
            // const signatureEx4 = web3.eth.accounts.sign(aBytes32, process.env.METAMASK_PRIVATE_KEY).signature
            // console.log('Signature : ' + signatureEx4)

            // await evaluator.ex4_manageWhiteListWithSignature(
            //     aBytes32,
            //     signatureEx4,
            //     {
            //     from: myWallet
            //     }
            // );

            // Exo_5 //  msg.sender = evaluator contract address but tx.origin = myWallet that call the evaluator
            const dataToSign = web3.utils.soliditySha3("0x657e2603c61eC6562258d72ce9E2C27E8537F81C", myWallet, myERC721Address);
            console.log(dataToSign)
            const signatureEx5 = web3.eth.accounts.sign(dataToSign, process.env.METAMASK_PRIVATE_KEY).signature
            console.log(signatureEx5)

            await evaluator.ex5_mintATokenWithASpecificSignature(
                signatureEx5,
                {
                from: myWallet
                }
            );
        // });
    });
});