pragma solidity ^0.6.0;
import "./IExerciceSolution.sol";
import "./MyERC721.sol";

contract Minter is IExerciceSolution {

    MyERC721 public myERC721Instance;
    mapping(address => bool) public whitelisted;

    constructor(MyERC721 _myERC721Instance) public 
    {
        myERC721Instance = _myERC721Instance;
        whitelisted[msg.sender] = true;
    }

	function ERC721Address() external override returns (address)
    {
        return address(myERC721Instance);
    }

	function mintATokenForMe() external override returns (uint256)
    {   
        uint256 newTokenId = myERC721Instance.publicMint(msg.sender);
        return newTokenId;
    }

	function mintATokenForMeWithASignature(bytes calldata _signature) external override returns (uint256)
    {
        bytes32 expectedSignedData = keccak256(abi.encodePacked(msg.sender, tx.origin, address(myERC721Instance)));
        require(signerIsWhitelistedInternal(expectedSignedData, _signature), "signature is not provided by an authorized minter");
        return mintATokenForMeInternal();
    }

	function getAddressFromSignature(bytes32 _hash, bytes calldata _signature) external override returns (address)
    { // Exo_3
        bytes memory signature = _signature;
        bytes32 r;
        bytes32 s;
        uint8 v;
        // Check the signature length
        if (signature.length != 65) {
            return address(0);
        }
        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
          r := mload(add(signature, 32))
          s := mload(add(signature, 64))
          v := byte(0, mload(add(signature, 96)))
        }
        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) 
        {
          v += 27;
        }
        // If the version is correct return the signer address
        if (v != 27 && v != 28) 
        {
          return address(0);
        } else {
          // solium-disable-next-line arg-overflow
          return ecrecover(keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
          ), v, r, s);
        }
    }
	function signerIsWhitelisted(bytes32 _hash, bytes calldata _signature) external override returns (bool)
    {
      return whitelisted[getAddressFromSignatureInternal(_hash, _signature)];
    }
	function whitelist(address _signer) external override returns (bool)
    {
      return whitelisted[_signer];
    }

    // Because the IExerciceSolution interface methods are external, 
    // I have to redefine them bellow to call them internally from this contract

    function signerIsWhitelistedInternal(bytes32 _hash, bytes memory _signature) internal returns (bool)
    {
       return whitelisted[getAddressFromSignatureInternal(_hash, _signature)];
    }

	function mintATokenForMeInternal() internal returns (uint256)
    {   
        uint256 newTokenId = myERC721Instance.publicMint(msg.sender);
        return newTokenId;
    }

    function getAddressFromSignatureInternal(bytes32 _hash, bytes memory signature) internal returns (address)
    { // Exo_3
        bytes32 r;
        bytes32 s;
        uint8 v;
        // Check the signature length
        if (signature.length != 65) {
            return address(0);
        }
        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
          r := mload(add(signature, 32))
          s := mload(add(signature, 64))
          v := byte(0, mload(add(signature, 96)))
        }
        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) 
        {
          v += 27;
        }
        // If the version is correct return the signer address
        if (v != 27 && v != 28) 
        {
          return address(0);
        } else {
          // solium-disable-next-line arg-overflow
          return ecrecover(keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
          ), v, r, s);
        }
    }

}