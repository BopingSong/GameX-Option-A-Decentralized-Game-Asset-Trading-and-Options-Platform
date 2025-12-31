// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameAssetPlus is ERC1155, Ownable {
    uint256 public nextTokenId = 1;

    enum GameID { DOTA2, CSGO }

    struct AssetMetadata {
        string name;
        string rarity;
        string itemType;
        string role;
        uint256 power;
        string uri;
        GameID game;
    }

    mapping(uint256 => AssetMetadata) public assetMetadata;

    constructor(string memory baseUri, address initialOwner)
        ERC1155(baseUri)
        Ownable(initialOwner)
    {}

    function mint(
        address to,
        uint256 amount,
        string memory name,
        string memory rarity,
        string memory itemType,
        string memory role,
        uint256 power,
        string memory metadataUri,
        GameID game
    ) external onlyOwner {
        uint256 tokenId = nextTokenId++;
        _mint(to, tokenId, amount, "");
        assetMetadata[tokenId] = AssetMetadata(name, rarity, itemType, role, power, metadataUri, game);
    }

    function mintFromSteamData(
        address to,
        uint256 amount,
        string memory name,
        string memory itemType,
        string memory role,
        uint256 power,
        GameID game
    ) external onlyOwner {
        string memory defaultRarity = "Common";
        string memory defaultUri = "https://gamex.io/metadata/default.json";

        uint256 tokenId = nextTokenId++;
        _mint(to, tokenId, amount, "");
        assetMetadata[tokenId] = AssetMetadata(name, defaultRarity, itemType, role, power, defaultUri, game);
    }

    function batchMint(
        address to,
        uint256[] memory amounts,
        AssetMetadata[] memory metadatas
    ) external onlyOwner {
        require(amounts.length == metadatas.length, "Length mismatch");
        uint256[] memory ids = new uint256[](amounts.length);
        for (uint256 i = 0; i < amounts.length; i++) {
            uint256 tokenId = nextTokenId++;
            ids[i] = tokenId;
            assetMetadata[tokenId] = metadatas[i];
        }
        _mintBatch(to, ids, amounts, "");
    }

    function getMetadata(uint256 tokenId) external view returns (AssetMetadata memory) {
        return assetMetadata[tokenId];
    }
}
