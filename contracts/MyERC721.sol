// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyERC721 is ERC721 {

    uint256 private nextTokenId;

    constructor() public ERC721("Test", "TST") {}

    function publicMint(address recipient) external returns(uint256){

        nextTokenId += 1;
        _mint(recipient,nextTokenId);

        return nextTokenId;
    }
}