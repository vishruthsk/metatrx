// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract token is ERC20{
    constructor() ERC20(" "," "){

    }
    function freemint(uint256 amount)public {
        _mint(msg.sender, amount);
    }

}

contract tokensender{
    using ECDSA for bytes32;
    mapping(bytes32 => bool) executed;
    function transfer(address sender, uint256 amount, address recipient, address tokencontract,bytes memory signature,uint nonce) public {
        bytes32 messagehash= gethash(sender, amount, recipient, tokencontract, nonce);
        bytes32 signedmessagehash= messagehash.toEthSignedMessageHash();
        require(!executed[signedmessagehash],"already executed");
        address signer = signedmessagehash.recover(signature);
        require(signer == sender,"sender not same");
        executed[signedmessagehash]=true;
        bool sent = ERC20(tokencontract).transferFrom(sender, recipient, amount);
        require(sent, "transfer failed");

    }

    function gethash(address sender, uint256 amount, address recipient, address contract_add, uint nonce) public pure returns(bytes32){
        return keccak256(abi.encodePacked(sender, amount, recipient, contract_add, nonce));
    }
}
