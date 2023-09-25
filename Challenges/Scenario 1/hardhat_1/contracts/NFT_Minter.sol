//SPDX-License-Identifier: GLWTPL
pragma solidity 0.8.16;

//This is an extension of the ERC721 contract which allows for the retrieval of all tokens that a wallet owns
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

//The following imported contracts are all for Polygon ID

//This is a contract that we will use to handle the verification tasks
import {ZKPVerifier} from "@iden3/contracts/verifiers/ZKPVerifier.sol";

//Importing an interface for interacting with the Circuit Validator
import {ICircuitValidator} from "@iden3/contracts/interfaces/ICircuitValidator.sol";

//This contract contains general utility functions for iden3 contracts
import {GenesisUtils} from "@iden3/contracts/lib/GenesisUtils.sol";

contract Minter is ERC721Enumerable, ZKPVerifier {

    //Address => ZKPVerificationRequestID => Verified or not
    mapping(address => mapping(uint256 => bool)) private hasVerified;

    //Error has not verified defined as a gas efficient & storage efficient method for error revertion when 
    //the 2 wallets have not went through verification
    error HasNotVerified();

    //Intializing the state of the contract through the constructor
    //name => The name of the ERC721 collection
    //symbol => The symbol ticker that is a shortened version of the name normaly e.g. Bitcoin => BTC
    //NFTreceiver => The wallet address that will receive the first NFT
    //ERC721(name,symbol) => Initializing the constructor of the inherited ERC721 contract
    constructor(string memory name, string memory symbol, address NFTreceiver) ERC721(name,symbol){
 
        //Mint NFT token ID 1 to the receiver
        _mint(NFTreceiver,1);
    }

    function _beforeProofSubmit(
        uint64, /* requestId */
        uint256[] memory inputs,
        ICircuitValidator validator
    ) internal view override {
        //Do something
    }

    function _afterProofSubmit(
        uint64 requestId,
        uint256[] memory inputs,
        ICircuitValidator validator
    ) internal override {
        //Do something
    }

    function _beforeTokenTransfer(
        address from, 
        address to, 
        uint256 firstTokenId, 
        uint256 batchSize
    ) internal virtual override {
        //Assuming that the request ID for verifying that location is 1
        if(!hasVerified[from][1] || !hasVerified[to][1]) revert HasNotVerified();
    }

}