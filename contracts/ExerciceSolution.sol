// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IExerciceSolution.sol";

import { IPool } from "./IPool.sol";
import { DataTypes } from "./DataTypes.sol";

import "./FlashLoan.sol";
import "./Evaluator.sol";

contract ExerciceSolution is IExerciceSolution
{
   address private constant daiAddress = 0xBa8DCeD3512925e52FE67b1b5329187589072A55;
   address private constant usdcAddress = 0x65aFADD39029741B3b8f0756952C74678c9cEC93;
   // pool proxy aavee
   address private constant poolAddress = 0x7b5C526B7F8dfdff278b4a3e045083FBA4028790;

   address private constant flashLoanAddress = 0x7b5C526B7F8dfdff278b4a3e045083FBA4028790;

   constructor() public {} 

   function depositSomeTokens() override external{

      // approve aavee pool
      IERC20(daiAddress).approve(poolAddress, 10*10**18);
      // deposit in aavee
      IPool(poolAddress).supply(daiAddress, 10*10**18, address(this), 0);
   }

   function withdrawSomeTokens() override external{

     IPool(poolAddress).withdraw(daiAddress, 1*10**18, address(this));   
   }

   function borrowSomeTokens() override external {

      // borrow from aavee
      IPool(poolAddress).borrow(usdcAddress, 1*10**6,  2, 0, address(this));
   }


   function repaySomeTokens() override external {

      IERC20(usdcAddress).approve(poolAddress, 10*10**6);

      IPool(poolAddress).repay(usdcAddress, uint(-1), 2, address(this));
   }

   function doAFlashLoan() override external {

      // Borrow 1M USDC (0.09% fee = 90k)
      FlashLoan(flashLoanAddress).requestFlashLoan(usdcAddress, 2000000*10**6);
   }

   function doAFlashLoanTEST(address _flashLoanAddress) external {

      // Borrow 1M USDC (0.09% fee = 900$ for 1M)
      FlashLoan(_flashLoanAddress).requestFlashLoan(usdcAddress, 2000000*10**6);
   }

   function repayFlashLoan() override external {}

   // approve flashloan to spend
   function approveUSDC(address _flashLoanAddress, uint256 _amount) external returns (bool) {
      return IERC20(usdcAddress).approve(_flashLoanAddress, _amount);
   }

   function getBalance(address _tokenAddress) external view returns (uint256) {
      return IERC20(_tokenAddress).balanceOf(address(this));
    }

   function callEvaluatorWith1M(address _flashLoanAddress, address payable _evaluatorAddress) external {

      // Evaluator(_evaluatorAddress).ex9_performFlashLoan();

      IERC20(usdcAddress).transfer(_flashLoanAddress, 1100000*10**6);
   }
}