// contracts/MyContract.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./GameOwner.sol";

contract SunflowerLandInventory is ERC1155Supply, GameOwner, Pausable {
    constructor() ERC1155("https://sunflower-land.com/play/erc1155/{id}.json") payable {
        gameRoles[msg.sender] = true;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function gameMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyGame {
        _mintBatch(to, ids, amounts, data);
    }

    function gameBurn(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public onlyGame {
        _burnBatch(to, ids, amounts);
    }

    function gameTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyGame {
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function gameSetApproval(
        address owner,
        address operator,
        bool approved
    ) internal virtual onlyGame {
        _setApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(!paused(), "ERC1155Pausable: token transfer while paused");
    }
}