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

contract Token is ERC20, ZKPVerifier {

    //Address => ZKPVerificationRequestID => boolean to track whether still verified
    mapping(address => mapping(uint256 => uint256)) private verifiedUntil;

    //Address => Day => Amount
    mapping(address => mapping(uint256 => uint256)) private transactedAmounts;
    
    //The time at which the contract was deployed
    uint256 private timeStarted;

    constructor(string memory name, string memory symbol, address tokenReceiver) ERC20(name, symbol) {
        _mint(tokenReceiver, 1000000 * (10 ** decimals())); // Minting 1 million tokens
        timeStarted = block.timestamp;
    }

    function _beforeProofSubmit(
        uint64, /* requestId */
        uint256[] memory inputs,
        ICircuitValidator validator
    ) internal view {
        //Do something
    }

    function _afterProofSubmit(
        uint64 requestId,
        uint256[] memory inputs,
        ICircuitValidator validator
    ) internal {
        //Do something
    }

    function getTotalTransferVolumeIn30Days(address query) private view returns (uint256) {
        uint256 day = (block.timestamp - timeStarted) / 86400;
        uint256 total = 0;
        uint256 startDay = day >= 30 ? day - 30 : 0;
        for (uint256 i = startDay; i <= day; i++) {
            total += transactedAmounts[query][i];
        }
        return total;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from != address(0)) { // Not a minting operation

            uint256 totalTransferredLast30Days = getTotalTransferVolumeIn30Days(from);

            // If the accumulated amount exceeds 5000 and the user hasn't been AML verified recently, revert the transaction
            if (totalTransferredLast30Days + amount > 5000 * (10 ** decimals()) && verifiedUntil[from][1] < block.timestamp) { // Assuming 1 is the ZKPVerificationRequestID for this example
                revert HasNotVerified();
            }

            uint256 day = (block.timestamp - timeStarted) / 86400;
            transactedAmounts[from][day] += amount;
        }
    }
}
