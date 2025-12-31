// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./contracts/token/ERC1155/IERC1155.sol";
import "./contracts/token/ERC20/ERC20.sol";
import "./contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./contracts/access/Ownable.sol";
import "./IFractionalizationModule.sol";


contract FractionalizationModule is Ownable {
    IERC1155 public gameAsset;

    struct LockedNFT {
        address originalOwner;
        uint256 amount;
        bool redeemed;
    }

    mapping(uint256 => LockedNFT) public lockedNFTs;
    mapping(uint256 => address) public fractionalTokens;

    constructor(address _gameAssetAddress, address initialOwner) Ownable(initialOwner) {
        gameAsset = IERC1155(_gameAssetAddress);
    }

    function fractionalize(
        uint256 tokenId,
        uint256 nftAmount,
        uint256 totalFractions,
        string memory name,
        string memory symbol
    ) external {
        require(lockedNFTs[tokenId].originalOwner == address(0), "Already fractionalized");

        gameAsset.safeTransferFrom(msg.sender, address(this), tokenId, nftAmount, "");

        FractionalToken fToken = new FractionalToken(name, symbol, totalFractions, msg.sender);
        fractionalTokens[tokenId] = address(fToken);

        lockedNFTs[tokenId] = LockedNFT({
            originalOwner: msg.sender,
            amount: nftAmount,
            redeemed: false
        });
    }

    function redeem(uint256 tokenId) external {
        LockedNFT storage locked = lockedNFTs[tokenId];
        require(!locked.redeemed, "Already redeemed");
        require(locked.originalOwner != address(0), "Not fractionalized");

        ERC20Burnable fToken = ERC20Burnable(fractionalTokens[tokenId]);
        require(fToken.balanceOf(msg.sender) == fToken.totalSupply(), "Need 100% ownership");

        fToken.burnFrom(msg.sender, fToken.totalSupply());

        locked.redeemed = true;

        gameAsset.safeTransferFrom(address(this), msg.sender, tokenId, locked.amount, "");
    }

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) public pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) public pure returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

contract FractionalToken is ERC20, ERC20Burnable {
    constructor(string memory name, string memory symbol, uint256 initialSupply, address owner)
        ERC20(name, symbol)
    {
        _mint(owner, initialSupply);
    }
}
