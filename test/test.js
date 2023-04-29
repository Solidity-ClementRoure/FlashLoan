// truffle run verify ExerciceSolution@0x5f451D07e14cd9873C95c2299108A92b399FC57a --network goerli

// truffle test debug --network goerli_fork test/test.js

const IERC20 = artifacts.require("IERC20");
const ExerciceSolution = artifacts.require("ExerciceSolution");
const FlashLoan = artifacts.require("FlashLoan");

const Evaluator = artifacts.require("Evaluator");
var TDErc20 = artifacts.require("ERC20TD.sol");

contract("ExerciceSolution", async (accounts) => {

    const daiAddress = "0xBa8DCeD3512925e52FE67b1b5329187589072A55";
    const usdcAddress = "0x65aFADD39029741B3b8f0756952C74678c9cEC93";

    const myWallet = "0x7bBfecDCF7d0E7e5aA5fffA4593c26571824CB87";

    // // deploy contracts
    // beforeEach(async function () {
    //     this.exerciceSolution = await ExerciceSolution.new();
    //     this.flashLoan = await FlashLoan.new(this.exerciceSolution.address);
    // });

    it("Should FlashLoan", async()=>{

        // Deploy test Evaluator
        const tdToken = await TDErc20.new("TD-AAVE-101","TD-AAVE-101",web3.utils.toBN("42000000000000000000000000000"));
        const evaluator = await Evaluator.new(
            tdToken.address, 
            "0xBa8DCeD3512925e52FE67b1b5329187589072A55",
            "0x65aFADD39029741B3b8f0756952C74678c9cEC93", 
            "0x4DAe67e69aCed5ca8f99018246e6476F82eBF9ab"
        );

        // my contracts
        const exerciceSolution = await ExerciceSolution.new();
        const flashLoan = await FlashLoan.new(exerciceSolution.address, evaluator.address);

        // init evaluator
        await tdToken.setTeacher(evaluator.address, true);
        await evaluator.submitExercice(exerciceSolution.address);

        // send USDC to the contract (cover the 0.09% fee = 1800$ for 2M)
        const usdcToken = await IERC20.at(usdcAddress);
        const amount = 2000*10**6;
        await usdcToken.transfer(flashLoan.address, amount, { from: myWallet });

        const input = await exerciceSolution.getBalance(usdcAddress);
        console.log(exerciceSolution.address);
        console.log("INPUT: ");
        console.log(input.toNumber());

        await exerciceSolution.doAFlashLoanTEST(
            flashLoan.address,
            {
                from: myWallet
            }
        );

        const output = await exerciceSolution.getBalance(usdcAddress);
        console.log("OUTPUT: ");
        console.log(output.toNumber());
    });

    // it("Should Deposit", async()=>{

    //     // migrate exerciceSolution contract
    //     const exerciceSolution = await ExerciceSolution.new();

    //     // send token to contract
    //     const daiToken = await IERC20.at(daiAddress);
    //     const amount = web3.utils.toWei('10', 'ether');
    //     await daiToken.transfer(exerciceSolution.address, amount, { from: myWallet });

    //     // call method to test
    //     await exerciceSolution.depositSomeTokens(
    //         {
    //             from: myWallet
    //         }
    //     );

    // });

    // // Should be called adter Deposit on same ExerciceSolution contract
    // it("Should Borrow", async()=>{

    //     // migrate exerciceSolution contract
    //     const exerciceSolution = await ExerciceSolution.new();

    //     // send token to contract
    //     // const amount = web3.utils.toWei('0.001', 'ether');
    //     // await web3.eth.sendTransaction({
    //     //     from: myWallet,
    //     //     to: exerciceSolution.address,
    //     //     value: amount
    //     // })

    //     // call method to test
    //     await exerciceSolution.borrowSomeTokens(
    //         {
    //             from: myWallet
    //         }
    //     );
    // });
});