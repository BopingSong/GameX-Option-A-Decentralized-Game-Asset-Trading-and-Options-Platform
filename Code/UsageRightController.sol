
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGameAsset1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);
}

interface IFractionalERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract UsageRightController {
    IFractionalERC20 public fractionalToken;
    IGameAsset1155 public gameAsset;

    uint256 public gameAssetTokenId;
    uint256 public minimumPercentageRequired = 30;
    uint256 public dailyUsageSeconds = 3600;

    struct UsageInfo {
        uint256 lastUsed;
        uint256 usedDuration;
    }

    mapping(address => UsageInfo) public usageInfo;

    constructor(address _fractionalToken, address _gameAsset, uint256 _tokenId) {
        fractionalToken = IFractionalERC20(_fractionalToken);
        gameAsset = IGameAsset1155(_gameAsset);
        gameAssetTokenId = _tokenId;
    }

    function eligible(address user) public view returns (bool) {
        uint256 total = fractionalToken.totalSupply();
        uint256 userBalance = fractionalToken.balanceOf(user);
        uint256 percent = (userBalance * 100) / total;

        return percent >= minimumPercentageRequired;
    }

    function canUse(address user) public view returns (bool) {
        UsageInfo memory info = usageInfo[user];

        if (block.timestamp - info.lastUsed >= 1 days) {
            return eligible(user);
        }
        return eligible(user) && info.usedDuration < dailyUsageSeconds;
    }

    function markUsage(uint256 durationSeconds) external {
        require(durationSeconds <= dailyUsageSeconds, "Exceeds daily limit");
        require(canUse(msg.sender), "Not eligible or already used enough");

        UsageInfo storage info = usageInfo[msg.sender];

        if (block.timestamp - info.lastUsed >= 1 days) {
            info.usedDuration = 0;
            info.lastUsed = block.timestamp;
        }

        require(info.usedDuration + durationSeconds <= dailyUsageSeconds, "Usage overflow");

        info.usedDuration += durationSeconds;
    }

    function resetDailyUsage(address user) external {
        usageInfo[user].usedDuration = 0;
        usageInfo[user].lastUsed = block.timestamp;
    }

    function setMinimumPercentage(uint256 newPercentage) external {
        require(newPercentage <= 100, "Invalid percentage");
        minimumPercentageRequired = newPercentage;
    }

    function setDailyUsageLimit(uint256 newLimitSeconds) external {
        dailyUsageSeconds = newLimitSeconds;
    }
}
