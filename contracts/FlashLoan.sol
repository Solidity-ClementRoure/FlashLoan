// SPDX-License-Identifier: MIT
pragma solidity 0.6.2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IFlashLoanSimpleReceiver.sol";
import "./IPoolAddressesProvider.sol";
import "./ExerciceSolution.sol";

contract FlashLoan is IFlashLoanSimpleReceiver {

    address payable owner;
    address exerciceSolutionAddress;
    address payable evaluatorAddress;
    // pool proxy aavee
    address private constant poolAddress = 0x7b5C526B7F8dfdff278b4a3e045083FBA4028790;
    address private constant usdcAddress = 0x65aFADD39029741B3b8f0756952C74678c9cEC93;

    constructor(address _exerciceSolutionAddress, address _evaluatorAddress) public
    {
        owner = payable(msg.sender);
        exerciceSolutionAddress = _exerciceSolutionAddress;
        evaluatorAddress = payable(_evaluatorAddress);
    }

    // STEP 2 (Automatically called after STEP 1)
    // This function is called after your contract has received the flash loaned amount
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        
        // This contract now has the funds requested.
        // Your logic goes here.

        // At the end of your logic above, this contract owes
        // the flashloaned amount + premiums.
        // Therefore ensure your contract has enough to repay
        // these amounts.

        // CODE (have to earn money here)
        
        
        // send 1M benefits to ExerciceSolution
        IERC20(usdcAddress).transfer(exerciceSolutionAddress, 1100000*10**6);

        ExerciceSolution(exerciceSolutionAddress).callEvaluatorWith1M(address(this), evaluatorAddress);

        // Approve the Pool contract allowance to *pull* the owed amount
        uint256 amountOwed = amount + premium; // prenium = 0.09% = 900$ if 1M borrowed
        IERC20(asset).approve(poolAddress, amountOwed);

        return true;
    }

    // STEP 1
    // Allows smartcontracts to access the liquidity of the pool within one transaction, as long as the amount taken plus a fee is returned
    function requestFlashLoan(address _token, uint256 _amount) public {
        address receiverAddress = address(this);
        address asset = _token;
        uint256 amount = _amount;
        bytes memory params = "";
        uint16 referralCode = 0;

         IPool(poolAddress).flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }

    function ADDRESSES_PROVIDER() override external view returns(IPoolAddressesProvider) {

        return IPoolAddressesProvider(poolAddress);
    }

    function POOL() override external view returns(IPool) {

       return IPool(poolAddress);
    }

    function getBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }
}